class Product < ActiveRecord::Base

  include Imagable
  include Orderable
  include Descriptiontable

  OFFICIAL_AGENT_NAME = 'UBOSS创客权'.freeze

  # FIXME: @dalezhang 请使用helper or i18n 做view的数值显示
  DataCalculateWay = { 0 => '按金额', 1 => '按售价比例' }
  DataBuyerPay = { 0 => '包邮', 1 => '统一邮费', 2 => '运费模板' }

  has_one_image autosave: true
  #has_many_images name: :figure_images, accepts_nested: true

  belongs_to :user
  belongs_to :carriage_template
  has_many :order_items
  has_many :product_inventories, autosave: true, dependent: :destroy
  has_many :cart_items,  through: :product_inventories
  has_many :seling_inventories, -> { where(saling: true) }, class_name: 'ProductInventory', autosave: true

  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img

  enum status: { unpublish: 0, published: 1, closed: 2 }

  scope :hots, -> { where(hot: true) }
  scope :available, -> { where.not(status: 2) }

  validates_presence_of :user_id, :name, :short_description
  validate :must_has_one_product_inventory

  before_create :generate_code

  def self.official_agent
    official_account = User.official_account
    return nil if official_account.blank?
    @official_agent_product ||= find_by(user_id: official_account.id, name: OFFICIAL_AGENT_NAME)
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

  def calculate_ship_price(count, user_address)
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

  def sku_hash
    skus = {}
    sku_details = {}
    # FIXME 不要使用毫无意义的变量名 obj, k , v ~
    self.seling_inventories.where("count > 0").each do |obj|
      obj.sku_attributes.each do |k,v|
        if !skus[k].present?
          skus[k] = {}
        end
        if !skus[k][v].present?
          skus[k][v] = []
        end
        skus[k][v] << obj.id
      end

      if !sku_details[obj.id].present?
        sku_details[obj.id] = {}
      end
      sku_details[obj.id][:count] = obj.count
      sku_details[obj.id][:sku_attributes] = obj.sku_attributes
      sku_details[obj.id][:price] = obj.price
    end
    hash = {}
    hash[:skus] = skus
    hash[:sku_details] = sku_details
    return hash
  end

  private

  def must_has_one_product_inventory
    errors.add(:product_inventories, '至少添加一个产品规格属性') unless product_inventories.size > 0
  end

end
