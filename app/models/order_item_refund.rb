class OrderItemRefund < ActiveRecord::Base
  belongs_to :order_item
  belongs_to :refund_reason
  has_many :refund_messages
  has_many :asset_imgs, class_name: 'AssetImg', autosave: true, as: :resource

  before_create :check_can_create?
  after_create  :set_order_item_state

  include AASM
  aasm do
    #申请退款
    state :pending, initial: true
    #同意
    state :approved,                 after_enter: :update_order_item_state_4
    #拒绝
    state :declined,                 after_enter: :update_order_item_state_4
    #确认收货
    state :confirm_received,         after_enter: :update_order_item_state_4
    #拒绝收货
    state :decline_received,         after_enter: :update_order_item_state_4
    #申请uboss介入
    state :applied_uboos,            after_enter: :update_order_item_state_7
    #买家填写快递单号
    state :completed_express_number, after_enter: :update_order_item_state_4
    #完成
    state :finished,                 after_enter: :update_order_item_state_5
    #撤销
    state :cancelled,                after_enter: :update_order_item_state_6

    #guard: :check_can_start?
    event :approve do
      transitions from: :pending, to: :approved
    end

    event :complete_express_number do
      transitions from: [:approved, :decline_received], to: :completed_express_number
    end

    event :confirm_receive do
      transitions from: :completed_express_number, to: :confirm_received
    end

    event :decline_receive do
      transitions from: :completed_express_number, to: :decline_received
    end

    event :apply_uboos do
      transitions from: [:completed_express_number, :decline_received, :declined], to: :applied_uboos
    end

    event :finish do
      transitions from: [:approved, :confirm_receive], to: :finished
    end


    event :cancel do
      transitions from: [:pending, :approved, :completed_express_number, :decline_received], to: :cancelled
    end
  end

  def check_can_create?
    #检查order同一状态下是否已经有过申请
  end

  def image_files
    self.asset_imgs.map{ |img| img.avatar.file.filename }.join(',')
  end

  private

  (4..7).each do |refund_state|
    define_method "update_order_item_state_#{refund_state}" do
      self.order_item.update_attributes!(refund_state: refund_state)
    end
  end

  def set_order_item_state
    if self.order.payed?
      self.order_item.update_attributes!(refund_state: 1)
    elsif self.order.shiped?
      # TODO refund_type 退款 or 退款退货
      self.order_item.update_attributes!(refund_state: 3)
    else
      # TODO refund_type 退款 or 退款退货
      self.order_item.update_attributes!(refund_state: 3)
    end
  end

end
