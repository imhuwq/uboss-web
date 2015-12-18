class Product < ActiveRecord::Base

  include Imagable
  include Orderable
  include Descriptiontable

  OFFICIAL_AGENT_NAME = 'UBOSS创客权'.freeze

  # FIXME: @dalezhang 请使用helper or i18n 做view的数值显示
  DataCalculateWay = { 0 => '按金额', 1 => '按售价比例' }
  DataBuyerPay = { 0 => '包邮', 1 => '统一邮费', 2 => '运费模板' }
  FullCut = { 0 => '件', 1 => '元' }

  has_one_image autosave: true
  #has_many_images name: :figure_images, accepts_nested: true

  belongs_to :user
  belongs_to :carriage_template
  has_many :different_areas, through: :carriage_template
  has_many :order_items
  has_and_belongs_to_many :categories, -> { uniq } ,autosave: true
  has_many :product_inventories, autosave: true, dependent: :destroy
  has_many :cart_items,  through: :product_inventories
  has_many :seling_inventories, -> { where(saling: true) }, class_name: 'ProductInventory', autosave: true

  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img


  # 店铺轮播图片 =>
  has_one_image name: :advertisement_img, autosave: true
  
  def  advertisement_img_url(option='')
    advertisement_img.try(:image_url,option)
  end

  def advertisement_img=(file)
    advertisement_img.avatar=(file)
  end

  def advertisement_img
    super || build_advertisement_img
  end
  # <-店铺轮播图片

  enum status: { unpublish: 0, published: 1, closed: 2 }

  scope :hots, -> { where(hot: true) }
  scope :available, -> { where.not(status: 2) }

  validates_presence_of :user_id, :name, :short_description
  validate :must_has_one_product_inventory
  validates :full_cut_number, :full_cut_unit, presence: true, if: "full_cut"
  validates_numericality_of :full_cut_number, greater_than: 0, if: "full_cut"

  before_create :generate_code
  after_create :add_categories_after_create

  validate do
    #统一邮费
    if transportation_way == 1
      self.errors.add(:traffic_expense, "不能小于或等于0") if traffic_expense.to_i <= 0
    #运费模板
    elsif transportation_way == 2
      self.errors.add(:carriage_template, "不能为空") if carriage_template_id.blank?
    end
  end

  def self.official_agent
    official_account = User.official_account
    return nil if official_account.blank?
    @official_agent_product ||= find_by(user_id: official_account.id, name: OFFICIAL_AGENT_NAME)
  end

  def max_price_inventory
    @max_price_inventory ||= seling_inventories.order('price DESC').first
  end

  def min_price_inventory
    @min_price_inventory ||= seling_inventories.order('price DESC').last
  end

  def max_price
    @max_price ||= max_price_inventory.price
  end

  def min_price
    @min_price ||= min_price_inventory.price
  end

  # SKU(product_inventory) 更新保存逻辑
  # 1. 更新OR创建新传入的SKU
  # 2. 正在销售的SKU，如果没有在传入的SKU规格参数中，这些SKU记录将会被Flag: saling -> false
  def product_inventories_attributes= attributes_collection
    unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
      raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
    end

    if attributes_collection.is_a? Hash
      keys = attributes_collection.keys
      attributes_collection = if keys.include?('id') || keys.include?(:id)
                                [attributes_collection]
                              else
                                attributes_collection.values
                              end
    end

    association = association(:product_inventories)

    unseling_ids = association.scope.saling.pluck(:id)
    existing_records = if association.loaded?
                         association.target
                       else
                         attribute_ids = attributes_collection.map {|a| a['sku_attributes'] || a[:sku_attributes] }.compact
                         attribute_ids.empty? ? [] : association.scope.where(sku_attributes: attribute_ids)
                       end

    attributes_collection.each do |attributes|
      attributes = attributes.with_indifferent_access

      existing_record = existing_records.detect { |record|
        record.sku_attributes.to_s == attributes['sku_attributes'].to_s
      }

      if existing_record
        # Make sure we are operating on the actual inventoryect which is in the association's
        # proxy_target array (either by finding it, or adding it if not found)
        # Take into account that the proxy_target may have changed due to callbacks
        target_record = association.target.detect { |record|
          record.sku_attributes.to_s == attributes['sku_attributes'].to_s
        }
        if target_record
          existing_record = target_record
        else
          association.add_to_target(existing_record, :skip_callbacks)
        end
        unseling_ids.delete(existing_record.id)
        attributes[:saling] = true
        existing_record.assign_attributes(attributes.except(*UNASSIGNABLE_KEYS))
      else
        association.build(attributes.except(*ActiveRecord::NestedAttributes::UNASSIGNABLE_KEYS))
      end
    end

    unseling_ids.each do |unseling_id|
      existing_record = existing_records.detect { |record| record.id.to_s == unseling_id.to_s }
      target_record = association.target.detect { |record| record.id.to_s == unseling_id.to_s }
      if target_record
        existing_record = target_record
      elsif existing_record
        association.add_to_target(existing_record, :skip_callbacks)
      else
        existing_record = association.scope.find(unseling_id)
        association.add_to_target(existing_record, :skip_callbacks)
      end
      existing_record.assign_attributes(saling: false)
    end
  end

  def traffic_expense
    @traffic_expense ||= if transportation_way == 2
                           different_areas.minimum(:carriage)
                         else transportation_way == 1
                           super
                         end
  end

  def asset_img
    super || build_asset_img
  end

  def generate_code
    loop do
      self.code = SecureRandom.hex(10)
      break unless Product.find_by(code: code)
    end
  end

  def is_official_agent?
    return @is_official_agent unless @is_official_agent.nil?
    @is_official_agent =
      user_id == User.official_account.try(:id) && name == OFFICIAL_AGENT_NAME
  end

  def total_sells
    order_items.joins(:order).where('orders.state > 2 AND orders.state <> 5').sum(:amount)
  end

  def calculate_ship_price(count, user_address, product_inventory_id=nil)
    return 0.0 if meet_full_cut?(count, product_inventory_id)
    if transportation_way == 1
      traffic_expense.to_f
    elsif transportation_way == 2 && user_address.try(:province)
      province = ChinaCity.get(user_address.province)
      carriage_template = CarriageTemplate.find(carriage_template_id)
      carriage_template.total_carriage(count, province)
    else
      0.0
    end
  end

  def meet_full_cut?(count, product_inventory_id)
    if self.full_cut
      Product::FullCut[self.full_cut_unit] == '件' ? check_full_cut_piece(count) : check_full_cut_yuan(count, product_inventory_id)
    end
  end

  def check_full_cut_piece(count)
    count >= full_cut_number
  end

  def check_full_cut_yuan(count, product_inventory_id)
    product_inventory = ProductInventory.find(product_inventory_id) if product_inventory_id
    ( count * product_inventory.price ) >= full_cut_number
  end

  def sku_hash
    skus = {}
    sku_details = {}
    count = 0
    self.seling_inventories.where("count > 0").each do |seling_invertory|
      seling_invertory.sku_attributes.each do |property_name,property_value|
        if !skus[property_name].present?
          skus[property_name] = {}
        end
        if !skus[property_name][property_value].present?
          skus[property_name][property_value] = []
        end
        skus[property_name][property_value] << seling_invertory.id
      end

      if !sku_details[seling_invertory.id].present?
        sku_details[seling_invertory.id] = {}
      end
      sku_details[seling_invertory.id][:count] = seling_invertory.count
      sku_details[seling_invertory.id][:sku_attributes] = seling_invertory.sku_attributes
      sku_details[seling_invertory.id][:price] = seling_invertory.price
      count += seling_invertory.count
    end
    hash = {}
    hash[:skus] = skus
    hash[:sku_details] = sku_details
    hash[:count] = count
    return hash
  end

  def categories=(category_names)
    unless category_names.is_a?(Array)
      category_names = category_names.split(',')
    end
    if self.new_record?
      @category_names = category_names
    else
      self.categories.clear
      category_names.each do |item|
        category = Category.find_or_create_by(name: item, user_id: self.user_id)
        self.categories << category
      end
    end
  end

  def add_categories_after_create
    if @category_names && @category_names.any?
      @category_names.each do |item|
        category = Category.find_or_create_by(name: item, user_id: self.user_id)
        category.user_id = self.user_id
        categories << category
      end
      save
    end
  end

  private

  def must_has_one_product_inventory
    errors.add(:product_inventories, '至少添加一个产品规格属性') unless product_inventories.size > 0
  end

end
