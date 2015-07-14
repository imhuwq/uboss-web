class WithdrawJob < ActiveJob::Base
  queue_as :default

  def perform(withdraw_record, ip='127.0.0.1')
    return false if withdraw_valid?(withdraw_record)

    transfer_amount  = if Rails.env.production?
                         (withdraw_record.amount * 100).to_i
                       else
                         1
                       end

    result = WxPay::Service.invoke_transfer(
      partner_trade_no: withdraw_record.number,
      openid: withdraw_record.user.weixin_openid,
      check_name: 'NO_CHECK',
      amount: transfer_amount,
      desc: '提现',
      spbill_create_ip: ip
    )

    Rails.logger.debug("transfer result: #{result}")

    if result.success?
      withdraw_record.update(
        wx_payment_no: result['payment_no'],
        wx_payment_time: result['payment_time'],
        error_info: nil
      )
      withdraw_record.finish!
    else
      withdraw_record.update(error_info: {code: result['return_code'], msg: result['return_msg']})
    end

  end

  private

  def withdraw_valid?(withdraw_record)
    if !withdraw_record.processed?
      withdraw_record.upate(
        error_info: {code: 'SYSTEM', msg: '状态错误'}
      )
    elsif withdraw_record.wx_payment_time.present?
      withdraw_record.upate(
        error_info: {code: 'SYSTEM', msg: '已打款', request_time: Time.now}
      )
    # 正在提现的资金存入的是frozen_income
    elsif withdraw_record.amount > withdraw_record.user.frozen_income
      withdraw_record.upate(
        error_info: {code: 'USER', msg: '非法的提现金额'}
      )
    end
  end

end
