class Product < ActiveRecord::Base

  include Orderable
  include Descriptiontable

  attr_accessor :attribute_name, :attribute_value

  OFFICIAL_AGENT_NAME = 'UBOSS创客权'.freeze

  # FIXME 请使用helper or i18n 做view的数值显示
  DataCalculateWay = { 0 => '按金额', 1 => '按售价比例' }
  DataBuyerPay = { true => '买家付款', false => '包邮' }

  validates_presence_of :user_id, :name, :short_description

  belongs_to :user
  has_one :asset_img, class_name: 'AssetImg', autosave: true, as: :resource
  has_many :product_share_issue, dependent: :destroy
  has_many :order_items

  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img

  enum status: { unpublish: 0, published: 1, closed: 2 }

  scope :hots, -> { where(hot: true) }

  before_create :generate_code
  before_save :calculates_before_save, :save_product_attributes

  def self.official_agent
    find_by(user_id: User.official_account.try(:id), name: OFFICIAL_AGENT_NAME)
  end

  def asset_img
    super || build_asset_img
  end

  def generate_code
    loop do
      self.code = SecureRandom.hex(10)
      break if !Product.find_by(code: code)
    end
  end

  def calculates_before_save
    calculate_share_amount_total
    set_share_rate
    calculate_shares
  end

  def calculate_share_amount_total # 如果按比例进行分成，将分成比例换算成实质分成总金额
    if calculate_way == 1
      self.share_amount_total = ('%.2f' % (present_price * share_rate_total * 0.01)).to_f # 价格×总分成比例=总分成金额
    end
  end

  def set_share_rate(*args) # 设置分成比例
    3.times do |index|
      rate = args[index] || get_shraing_rate(has_share_lv, index+1)
      self.__send__("share_rate_lv_#{index + 1}=", rate)
    end
  end

  def calculate_shares # 计算具体的分成金额
    if has_share_lv != 0 # 参与分成的情况
      assigned_total = 0

      3.times do |index|
        level = index + 1
        amount = (share_amount_total * self["share_rate_lv_#{level}"]).round(2)
        self.__send__("share_amount_lv_#{level}=", amount)
        assigned_total += amount
      end

      self.privilege_amount = share_amount_total - assigned_total
    end
  end

  def is_official_agent?
    user_id == User.official_account.id && name == OFFICIAL_AGENT_NAME
  end

  def total_sells
    order_items.joins(:order).where('orders.state > 2 AND orders.state <> 5').sum(:amount)
  end

  def save_product_attributes(hash={})
    new_hash = {}
    hash.each do |k,v|
      @attribute_name = ProductAttributeName.find_or_create_by_name(k)
      @attribute_value = ProductAttributeValue.find_or_create_by(product_attribute_name_id: @attribute_name.id, value: v)
      new_hash[k] = [v,@attribute_value.id]
    end
    @inventory = ProductInventory.find_or_create_by(product_id: self.id,attributes: new_hash)
    @inventory.update(count: self.count)
  end

  private
  def get_shraing_rate(sharing_level, rate_level)
    Rails.application.secrets.product_sharing["level#{sharing_level}"].try(:[], "rate#{rate_level}").to_f
  end
end
