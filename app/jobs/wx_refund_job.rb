class WxRefundJob < ActiveJob::Base
  queue_as :default

  def perform(order_item_refund)
    if $wechat_env.test?
      find_or_create_refund_record(
        order_item_refund,
        {
          return_code: 'SUCCESS',
          out_trade_no: order_item_refund.order_charge_number,
          total_fee: order_item_refund.total_fee,
          refund_fee: order_item_refund.money * 100,
          refund_channel: 'ORIGINAL'
        })

      test_wx_refund_query
    else
      invoke_weixin_refund(order_item_refund)
    end
  end

  private

  def invoke_weixin_refund(refund)
    tries ||= 3

    res = WxPay::Service.invoke_refund({
      out_trade_no:  refund.order_charge_number,
      total_fee:     refund.total_fee,
      refund_fee:    refund.money * 100,
      out_refund_no: refund.refund_number
    })

    unless res.success?
      raise
    end
    find_or_create_refund_record(refund, res)
  rescue
    tries -= 1
    tries > 0 ? retry : logger.info(res)
  end


  def find_or_create_refund_record(refund, res)
    record = refund.refund_record || refund.create_refund_record

    options = {applied_status: res['return_code']}
    if res['return_code'] == 'SUCCESS'
      options = {
        out_trade_no:   res['out_trade_no'],
        out_refund_no:  res['out_refund_no'],
        total_fee:      res['total_fee'],
        refund_fee:     res['refund_fee'],
        refund_channel: res['refund_channel']
      }.merge(options)
    end
    options.merge({applied_at: Time.current, applied_content: res})
    record.update_attribute(options)
  end

  def test_wx_refund_query
    RefundRecord.where(applied_status: 'SUCCESS', refund_status: [nil, 'PROCESSING'])
      .where("applied_at <= ? and applied_at >= ?", Time.now, Time.now - 15.days).find_each(batch_size: 500) do |record|

      res = {refund_status_0: ['SUCCESS', 'NOTSURE'].sample, refund_channel_0: 'ORIGINAL'}
      record.query_count += 1
      record.query_content = res

      record.transaction do
        if true
          if res['refund_status_0'] == 'SUCCESS'
            refund = record.order_item_refund
            refund.may_finish? && refund.finish!
            refund.order_item.update(order_item_refund_id: refund.id)
            record.refunded_at    = Time.current
          elsif res['refund_status_0'] == 'NOTSURE'
            WxRefundJob.perform_later(refund)
          end

          record.refund_status  = res['refund_status_0']
          record.refund_channel = res['refund_channel_0']
        end
        record.save
      end
    end
  end

end
