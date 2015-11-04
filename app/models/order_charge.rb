class OrderCharge < ActiveRecord::Base

  include Numberable

  FAKE_PREPAY_ID = 'fake-prepay-id'.freeze
  WXPAY_SUCCESS_FLAG = "SUCCESS".freeze

  belongs_to :user
  has_many :orders
  has_many :order_items, through: :orders

  validates_presence_of :user_id

  enum payment: { alipay: 0, alipay_wap: 1, alipay_qr: 2, wx: 3, wx_pub: 4, wx_pub_qr: 5, yeepay_wap: 6 }

  def self.unpay?(orders)
    bool = false
    orders.each { |order| bool = true if order.unpay? }
    bool
  end

  def self.check_and_close_prepay(opts = {})
    order_charges = opts[:order_charges]
    order_charges ||= where(id: opts[:ids])
    order_charges.each do |order_charge|
      unless order_charge.check_paid?
        order_charge.close_prepay
      end
    end
  end

  def reset_pay_serial_number
    set_number if number.blank?
    self.pay_serial_number = "#{number}-#{Time.current.to_i}"
  end

  def pay_amount
    orders.sum(:pay_amount)
  end

  def orders_check_paid
    ActiveRecord::Base.transaction do
      orders.each { |order| order.check_paid }
    end
  end

  def check_paid?
    return true if paid_at.present?

    if $wechat_env.test?
      update_with_wx_pay_result(
        "total_fee" => pay_amount * 100,
        "payment" => 'wx',
        "time_end" => Time.now
      )
      true
    else
      invoke_wx_pay_cheking
    end
  end
  alias_method :paid?, :check_paid?

  def update_with_wx_pay_result(result)
    paid_amount_result = Rails.env.production? ? (BigDecimal(result["total_fee"]) / 100) : pay_amount
    self.paid_amount = paid_amount_result
    self.payment = 'wx'
    self.paid_at = result['time_end']
    self.save(validate: false)
  end

  # 判断是否有效
  def wx_prepay_valid?
    return false if prepay_id == FAKE_PREPAY_ID && !$wechat_env.test?
    prepay_id.present? && Time.current.to_i <= prepay_id_expired_at.to_i
  end

  def close_prepay
    result = WxPay::Service.invoke_closeorder(out_trade_no: pay_serial_number)
    if result.success?
      discard_deal
    elsif result['return_code'] == WXPAY_SUCCESS_FLAG
      case result['err_code']
      when 'ORDERPAID'
        orders_check_paid
      else
        discard_deal
      end
    end
  end

  private
  def invoke_wx_pay_cheking
    response = WxPay::Service.order_query(out_trade_no: pay_serial_number)
    if response.success? && WxPay::Sign.verify?(response) && response['trade_state'] == 'SUCCESS'
      update_with_wx_pay_result(response)
      assign_paid_amount_to_order
      true
    else
      false
    end
  end

  def assign_paid_amount_to_order
    distribute_amount = self.paid_amount
    distribute_orders_size = orders.size

    orders.each_with_index do |order, index|
      order_paid_amount = if index == distribute_orders_size - 1
                            distribute_amount
                          else
                            distribute_amount >= order.pay_amount ? order.pay_amount : distribute_amount
                          end
      order.update_column :paid_amount, order_paid_amount
      distribute_amount -= order_paid_amount
    end
  end

  def discard_deal
    reload.orders.update_all order_charge_id: nil
    update_column :prepay_id_expired_at, Time.current
  end
end
