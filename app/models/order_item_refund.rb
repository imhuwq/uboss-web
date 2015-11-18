class OrderItemRefund < ActiveRecord::Base
  belongs_to :order_item
  belongs_to :refund_reason
  belongs_to :user
  has_one :sales_return
  has_one :refund_record
  has_many :refund_messages
  has_many :asset_imgs, class_name: 'AssetImg', autosave: true, as: :resource

  validates :order_state, :money, :refund_reason_id, presence: true
  validates_uniqueness_of :order_state, scope: :order_item_id

  validate do
    if money <= 0 || money > self.order_item.pay_amount
      self.errors.add(:money, "不能小于等于0或大于#{self.order_item.pay_amount}")
    end
  end

  after_create :save_state_at_attributes
  after_create  :set_order_item_state

  delegate :logistics_company, :ship_number, :description, to: :sales_return, allow_nil: true

  enum order_state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5, completed: 6 }

  extend Enumerize

  enumerize :refund_type, in: [:refund, :receipted_refund, :unreceipt_refund, :return_goods_and_refund, :after_sale_only_refund, :after_sale_return_goods_and_refund]

  include AASM
  aasm do
    #申请退款
    state :pending, initial: true
    #同意
    state :approved,                 after_enter: [:update_order_item_state_4, :set_deal_times, :wx_order_refund]
    #拒绝
    state :declined,                 after_enter: [:update_order_item_state_4, :set_deal_times]
    #确认收货
    state :confirm_received,         after_enter: [:update_order_item_state_4, :set_deal_times]
    #拒绝收货
    state :decline_received,         after_enter: [:update_order_item_state_4, :set_deal_times, :wx_order_refund]
    #申请uboss介入
    state :applied_uboss,            after_enter: [:update_order_item_state_7, :set_deal_times]
    #买家填写快递单号
    state :completed_express_number, after_enter: [:update_order_item_state_4, :set_deal_times]
    #完成
    state :finished,                 after_enter: [:update_order_item_state_5, :set_deal_times]
    #撤销（买家）
    state :cancelled,                after_enter: [:update_order_item_state_6, :set_deal_times]
    #关闭（待发货时申请退款，商家选择发货）
    state :closed,                   after_enter: [:update_order_item_state_6, :set_deal_times]

    event :approve do
      transitions from: [:pending, :declined, :applied_uboss], to: :approved
    end
    event :repending do
      transitions from: :declined, to: :pending
    end
    event :decline do
      transitions from: :pending, to: :declined
    end
    event :complete_express_number do
      transitions from: [:approved, :decline_received], to: :completed_express_number
    end
    event :confirm_receive do
      transitions from: [:decline_received, :completed_express_number, :applied_uboss], to: :confirm_received
    end
    event :decline_receive do
      transitions from: :completed_express_number, to: :decline_received
    end
    event :apply_uboss do
      transitions from: [:completed_express_number, :decline_received, :declined], to: :applied_uboss
    end
    event :finish do
      transitions from: [:approved, :confirm_receive], to: :finished
    end
    event :cancel do
      transitions from: [:pending, :approved, :completed_express_number, :decline_received, :applied_uboss], to: :cancelled
    end
    event :close do
      transitions from: [:pending], to: :closed
    end
  end

  def refund_type_include_goods?
    refund_type.to_s.include?('goods')
  end

  def save_state_at_attributes
    self.deal_at = time_now
    self.state_at_attributes = {'申请时间' => time_now}
    self.save
  end

  def time_now
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

  def image_files
    self.asset_imgs.map{ |img| img.avatar.file.filename }.join(',')
  end

  def create_timeout_message(timeout_days)
    if self.approved?
      if self.refund_type_include_goods?
        self.address = self.order_item.order.seller.default_post_address.try(:refund_label)
        self.save
        action  = "同意退货"
        message = "退货地址：#{self.address}</br>商家在#{timeout_days}天内未处理此申请，系统已默认商家同意此次申请"
      else
        action  = "同意退款"
        message = "商家在#{timeout_days}天内未处理此申请，系统已默认商家同意此次申请"
      end
    elsif self.confirm_received?
      action  = "确认收货"
      message = "商家在#{timeout_days}天内未确认收货，系统已默认商家已收货"
    end

    self.refund_messages.create(user_type: '卖家',
                                user_id: self.order_item.order.seller_id,
                                message: message,
                                action: action,
                                order_item_refund_id: id
                               )
  end

  def order_charge
    order_item.order.order_charge
  end

  def order_charge_number
    order_charge.number
  end

  def refund_number
    "#{order_charge_number}#{id}"
  end

  def total_fee
    order_charge.paid_amount * 100
  end

  private

  (4..7).each do |refund_state|
    define_method "update_order_item_state_#{refund_state}" do
      self.order_item.update_attributes!(refund_state: refund_state)
    end
  end

  def set_order_item_state
    if self.order_item.order.payed?
      self.order_item.update_attributes!(refund_state: 1)
    else
      if refund_type_include_goods?
        self.order_item.update_attributes!(refund_state: 3)
      else
        self.order_item.update_attributes!(refund_state: 2)
      end
    end
  end

  def set_deal_times
    case aasm_state
    when 'approved'
      self.state_at_attributes['同意时间'] = time_now
    when 'completed_express_number'
      self.state_at_attributes['退货时间'] = time_now
    when 'confirm_received'
      self.state_at_attributes['卖家确认收货时间'] = time_now
    when 'finished'
      self.state_at_attributes['退款时间'] = time_now
    when 'cancelled'
      self.state_at_attributes['关闭时间'] = time_now
    when 'closed'
      self.state_at_attributes['关闭时间'] = time_now
    end
    self.deal_at = time_now
    self.save
  end

  # 微信退款
  def wx_order_refund
    if self.approved? && !refund_type_include_goods?    # 如果只退款不退货, 同意退款申请后就直接进入退款流程
      WxRefundJob.perform_later(self)
    elsif self.confirm_received                         # 卖家确认收货
      WxRefundJob.perform_later(self)
    end
  end

end
