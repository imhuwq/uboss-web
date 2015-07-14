class WithdrawJob < ActiveJob::Base
  queue_as :default

  def perform(withdraw_record, ip='127.0.0.1')
    return false if !withdraw_record.processed?
    return false if withdraw_record.wx_payment_time.present?

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

end
