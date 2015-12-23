class WithdrawJob < ActiveJob::Base

  include Loggerable

  queue_as :default

  attr_reader :withdraw_record, :ip, :transfer_type, :result

  def perform(withdraw_record, opts = {ip: '127.0.0.1'})
    @withdraw_record = withdraw_record
    @ip = opts[:ip]
    @transfer_type = opts[:type]
    if @transfer_type == 'query'
      query
    else
      transfer
    end
  end

  private

  def transfer
    return false if withdraw_valid?(withdraw_record)

    invoke_weixin_transfer(withdraw_record, ip)
  rescue => e
    withdraw_record.update_error_info(code: 'PLATFORM', msg: e.message)
  end

  def query
    return false if withdraw_record.bank_processing?
    @result = WxPay::Service.invoke_transferquery(partner_trade_no: withdraw_record.number)
    process_result
    withdraw_record.update_error_info(requerying_done_at: Time.now)
  rescue => e
    withdraw_record.update_error_info(
      code: 'PLATFORM', msg: e.message
    )
  end

  def invoke_weixin_transfer(withdraw_record, ip)
    transfer_amount  = if Rails.env.production?
                         (withdraw_record.amount * 100).to_i
                       else
                         1
                       end

    @result = WxPay::Service.invoke_transfer(
      partner_trade_no: withdraw_record.number,
      openid: withdraw_record.user.weixin_openid,
      check_name: 'NO_CHECK',
      amount: transfer_amount,
      desc: '提现',
      spbill_create_ip: ip
    )

    logger.info "Transfer #{withdraw_record.number} result: #{result}"

    process_result
  end

  def process_result
    if result.success?
      withdraw_record.update(
        wx_payment_no: result['payment_no'],
        wx_payment_time: result['payment_time'],
      )
      withdraw_record.finish!
      logger.info "Transfer #{withdraw_record.number} SUCCESS, wx_payment_no: #{result['payment_no']}"
    else
      withdraw_record.update_error_info(
        code: result['return_code'],
        msg: result['return_msg']
      )
      withdraw_record.fail!
      logger.error "Transfer #{withdraw_record.number} FAIL, wx_payment_no: #{result['payment_no']}"
    end
  end

  def withdraw_valid?(withdraw_record)
    if !withdraw_record.processed?
      withdraw_record.update_error_info(
        code: 'SYSTEM', msg: '状态错误'
      )
    elsif withdraw_record.wx_payment_time.present?
      withdraw_record.update_error_info(
        code: 'SYSTEM', msg: '已打款', request_time: Time.now
      )
    # 正在提现的资金存入的是frozen_income
    elsif withdraw_record.amount > withdraw_record.user.frozen_income
      withdraw_record.update_error_info(
        code: 'USER', msg: '非法的提现金额'
      )
    end
  end

end
