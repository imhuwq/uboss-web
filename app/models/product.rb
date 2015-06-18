# encoding:utf-8
class Product < ActiveRecord::Base
  DataCalculateWay = { 0 => '按金额', 1 => '按售价比例' }
  DataBuyerPay = { true => '买家付款', false => '卖家付款' }

  validates_presence_of :user_id, :name

  has_one :asset_img, class_name: 'AssetImg', dependent: :destroy, as: :resource
  has_many :product_share_issue, dependent: :destroy

  before_create :generate_code
  before_save :calculates_before_save

  def generate_code
    self.code = UUIDTools::UUID.random_create.to_s.gsub!('-', '')[0..10]
  end

  def calculates_before_save
    calculate_share_amount_total
    set_default_share_rate
    calculate_shares
  end

  def calculate_share_amount_total # 如果按比例进行分成，将分成比例换算成实质分成总金额
    if self.calculate_way == 1
      self.share_amount_total = ('%.2f' % (present_price * share_rate_total * 0.01)).to_f # 价格×总分成比例=总分成金额
    end
  end

  def set_default_share_rate # 设置默认分成比例
    case has_share_lv  # 依据分成层数设定
    when 3 # 3层
      self.share_rate_lv_3 = 0.2
      self.share_rate_lv_2 = 0.3
      self.share_rate_lv_1 = 0.5
    when 2 # 2层
      self.share_rate_lv_3 = 0.0
      self.share_rate_lv_2 = 0.4
      self.share_rate_lv_1 = 0.6
    when 1 # 2层
      self.share_rate_lv_3 = 0.0
      self.share_rate_lv_2 = 0.0
      self.share_rate_lv_1 = 1.0
    when 0 # 不分成
      self.share_rate_lv_3 = 0.0
      self.share_rate_lv_2 = 0.0
      self.share_rate_lv_1 = 0.0
    end
  end

  def calculate_shares # 计算具体的分成金额
    unless has_share_lv == 0 # 参与分成的情况
      self.share_amount_lv_3 = ('%.2f' % (share_amount_total * share_rate_lv_3)).to_f
      self.share_amount_lv_2 = ('%.2f' % (share_amount_total * share_rate_lv_2)).to_f
      self.share_amount_lv_1 = (share_amount_total - share_amount_lv_2 - share_amount_lv_3)
    else
      self.share_amount_lv_3 = 0.0
      self.share_amount_lv_2 = 0.0
      self.share_amount_lv_1 = 0.0
    end
  end
end
