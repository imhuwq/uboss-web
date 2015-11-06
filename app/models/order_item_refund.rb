class OrderItemRefund < ActiveRecord::Base
  belongs_to :order_item
  belongs_to :refund_reason
  belongs_to :user
  has_one :sales_return
  has_many :refund_messages
  has_many :asset_imgs, class_name: 'AssetImg', autosave: true, as: :resource

  validates :order_state, presence: true, uniqueness: true
  after_create :save_state_at_attributes
  after_create  :set_order_item_state

  enum order_state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5, completed: 6 }

  extend Enumerize

  enumerize :refund_type, in: [:refund, :receipted_refund, :unreceipt_refund, :return_goods_and_refund, :after_sale_only_refund, :after_sale_return_goods_and_refund]

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

    event :approve do
      transitions from: [:pending, :applied_uboss], to: :approved
      after do
        #如果只退款不退货, 同意后就直接进入退款流程
        if !refund_type_include_goods?
          #打款给买家
          self.may_finish? && self.finish!
        end
        self.state_at_attributes['同意时间'] = time_now
        self.save
      end
    end

    event :decline do
      transitions from: :pending, to: :declined
    end

    event :complete_express_number do
      transitions from: [:approved, :decline_received], to: :completed_express_number
      after do
        self.state_at_attributes['退货时间'] = time_now
        self.save
      end
    end

    event :confirm_receive do
      transitions from: [:completed_express_number, :applied_uboss], to: :confirm_received
      after do
        self.state_at_attributes['卖家确认收货时间'] = time_now
        self.save
      end
    end

    event :decline_receive do
      transitions from: :completed_express_number, to: :decline_received
    end

    event :apply_uboss do
      transitions from: [:completed_express_number, :decline_received, :declined], to: :applied_uboss
    end

    event :finish do
      transitions from: [:approved, :confirm_receive], to: :finished
      after do
        self.state_at_attributes['退款时间'] = time_now
        self.save
      end
    end


    event :cancel do
      transitions from: [:pending, :approved, :completed_express_number, :decline_received, :applied_uboss], to: :cancelled
      after do
        self.state_at_attributes['关闭时间'] = time_now
        self.save
      end
    end
  end

  def refund_type_include_goods?
    refund_type.to_s.include?('goods')
  end

  def save_state_at_attributes
    self.state_at_attributes = {'申请时间' => time_now}
    self.save
  end

  def time_now
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
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
    if self.order_item.order.payed?
      self.order_item.update_attributes!(refund_state: 1)
    elsif self.order_item.order.shiped?
      # TODO refund_type 退款 or 退款退货
      self.order_item.update_attributes!(refund_state: 3)
    else
      # TODO refund_type 退款 or 退款退货
      self.order_item.update_attributes!(refund_state: 3)
    end
  end

end
