class OrderItemRefund < ActiveRecord::Base

  include AASM
  include Orderable
  extend Enumerize

  WAIT_SELLER_PROCESS_STATES = %w(pending completed_express_number applied_uboss)
  DONE_PROCESS_STATES = %w(finished cancelled closed)

  belongs_to :user
  belongs_to :order_item
  belongs_to :refund_reason
  has_one :sales_return
  has_one :refund_record
  has_many :refund_messages
  has_many :asset_imgs, class_name: 'AssetImg', autosave: true, as: :resource

  scope :with_seller, -> (seller_id) { joins(order_item: :order).where(orders: { seller_id: seller_id }) }
  scope :wait_seller_processes, -> { where(aasm_state: WAIT_SELLER_PROCESS_STATES) }
  scope :successed, -> {
    where(
      <<-SQL.squish!
        order_item_refunds.aasm_state IN ('finished', 'confirm_received') OR
        (order_item_refunds.aasm_state = 'approved' AND order_item_refunds.refund_type NOT LIKE '%goods%')
      SQL
    )
  }
  scope :progresses, -> { where(aasm_state: ['pending', 'approved', 'declined', 'decline_received', 'applied_uboss', 'completed_express_number']) }

  validates :order_state, :money, :refund_reason_id, presence: true
  validates_uniqueness_of :order_state, scope: :order_item_id, message: '不能多次申请'

  validate do
    if money <= 0 || money > self.order_item.pay_amount
      self.errors.add(:money, "不能小于等于0或大于#{self.order_item.pay_amount}")
    end
  end

  after_create :save_state_at_attributes

  delegate :logistics_company, :ship_number, to: :sales_return, allow_nil: true

  enum order_state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5, completed: 6 }

  enumerize :refund_type, in: [
    :refund,
    :receipted_refund,
    :unreceipt_refund,
    :return_goods_and_refund,
    :after_sale_only_refund,
    :after_sale_return_goods_and_refund
  ]

  aasm do
    #申请退款
    state :pending, initial: true
    #同意
    state :approved,                 after_enter: [:check_if_only_refund]
    #拒绝
    state :declined
    #确认收货
    state :confirm_received,         after_enter: [:wx_order_refund]
    #拒绝收货
    state :decline_received
    #申请uboss介入
    state :applied_uboss
    #买家填写快递单号
    state :completed_express_number
    #完成
    state :finished,                 after_enter: [:set_order_item]
    #撤销（买家）
    state :cancelled
    #关闭（待发货时申请退款，商家选择发货 or 带确认收货，买家选择收货）
    state :closed

    after_all_transitions :set_deal_times

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
      transitions(
        from: [:pending, :approved, :completed_express_number, :decline_received, :applied_uboss],
        to: :cancelled
      )
    end
    event :close do
      transitions from: [:pending], to: :closed
      transitions(
        from: [:pending, :declined, :completed_express_number, :decline_received, :applied_uboss],
        to: :closed,
        guards: [:order_shiped?]
      )
      transitions(
        from: [:approved],
        to: :closed,
        guards: [:order_shiped?, :refund_type_include_goods?]
      )
    end
  end

  def order_shiped?
    order_state == 'shiped'
  end

  def wait_seller?
    WAIT_SELLER_PROCESS_STATES.include?(aasm_state)
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

  def create_timeout_message
    if self.approved?
      if self.refund_type_include_goods?
        action  = "同意退货"
        message = "卖家退货地址【#{self.address}】</br>商家在#{Rails.application.secrets.refund_timeout['days_5']}天内未处理此申请，系统已默认商家同意此次申请"
      else
        action  = "同意退款"
        message = "商家在#{Rails.application.secrets.refund_timeout['days_2']}天内未处理此申请，系统已默认商家同意此次申请"
      end
    elsif self.confirm_received?
      action  = "确认收货"
      message = "商家在#{Rails.application.secrets.refund_timeout['days_10']}天内未确认收货，系统已默认商家已收货"
    end

    action.present? && self.refund_messages.create(
      user_type: '卖家',
      user_id: self.order_item.order.seller_id,
      message: message,
      action: action,
      order_item_refund_id: id
    )
  end

  def deal_with_timeout_refund
    case aasm_state
    when 'pending'
      timeout_approve if (refund_type == 'refund' && timeout_approve_refund?) || (refund_type != 'refund' && timeout_approve_return?)
    when 'approved'
      timeout_cancel  if refund_type_include_goods? && timeout_cancel?
      check_wx_refund if !refund_type_include_goods?   # 判断是否退款成功，然后finish退款申请
    when 'declined'
      timeout_cancel if timeout_cancel?
    when 'confirm_received'
      check_wx_refund                                  # 判断是否退款成功，然后finish退款申请
    when 'decline_received'
      timeout_cancel if timeout_cancel?
    when 'completed_express_number'
      timeout_confirm_receive if timeout_confirm_receive?
    end
  end

  def days_form_deal_at
    Time.current - deal_at
  end

  def timeout_approve_refund?
    days_form_deal_at > Rails.application.secrets.refund_timeout['days_2'].days
  end

  def timeout_approve_return?
    days_form_deal_at > Rails.application.secrets.refund_timeout['days_5'].days
  end

  def timeout_confirm_receive?
    days_form_deal_at > Rails.application.secrets.refund_timeout['days_10'].days
  end

  def timeout_cancel?
    days_form_deal_at > Rails.application.secrets.refund_timeout['days_7'].days
  end

  def timeout_approve
    may_approve? && approve! && create_timeout_message
  end

  def timeout_confirm_receive
    may_confirm_receive? && confirm_receive! && create_timeout_message
  end

  def timeout_cancel
    may_cancel? && cancel! && create_timeout_message
  end

  def check_wx_refund
    res = WxPay::Service.invoke_refundquery({ out_trade_no: order_charge_number })

    if res.success?
      if res['refund_status_0'] == 'SUCCESS'
        may_finish? && finish!
      elsif res['refund_status_0'] == 'NOTSURE'
        WxRefundJob.perform_later(self)
      end
      refund_record.update_with_refundquery_result(res)
    end
  end

  def order_charge
    order_item.order.order_charge
  end

  def order_charge_number
    order_charge.pay_serial_number
  end

  def refund_number
    "#{order_charge_number}#{id}"
  end

  def total_fee
    order_charge.paid_amount * 100
  end

  def deal_at
    super || updated_at
  end

  private

  def set_deal_times
    case aasm.to_state
    when :approved
      self.state_at_attributes['同意时间'] = time_now
    when :completed_express_number
      self.state_at_attributes['退货时间'] = time_now
    when :confirm_received
      self.state_at_attributes['卖家确认收货时间'] = time_now
    when :finished
      self.state_at_attributes['退款时间'] = time_now
    when :cancelled
      self.state_at_attributes['关闭时间'] = time_now
    when :closed
      self.state_at_attributes['关闭时间'] = time_now
    end
    self.deal_at = time_now
  end

  def set_order_item
    self.order_item.update(order_item_refund_id: self.id)
  end

  def check_if_only_refund
    if refund_type_include_goods?    # 如果只退款, 同意退款申请后就直接进入退款流程
      self.address = order_item.order.seller.default_post_address.try(:refund_label) ||'商家没有设定默认退货地址，请联系商家获取退货地址'
      self.save
    else
      wx_order_refund
    end
  end

  # 微信退款
  def wx_order_refund
    WxRefundJob.perform_later(self)
  end

end
