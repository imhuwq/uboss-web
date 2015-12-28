class CreateRefundRecords < ActiveRecord::Migration
  def change
    create_table :refund_records do |t|
      t.references :order_item_refund, index: true, foreign_key: true
      t.string     :out_trade_no             #商户订单号
      t.decimal    :total_fee,  default: 0.0 #总金额
      t.decimal    :refund_fee, default: 0.0 #退款金额
      t.string     :out_refund_no            #商户退款单号
      t.datetime   :applied_at               #申请时间
      t.string     :applied_status           #申请状态
      t.datetime   :refunded_at              #完成时间
      t.string     :refund_channel           #退款渠道
      t.string     :refund_status            #退款状态
      t.integer    :query_count, default: 0  #查询次数
      t.text       :applied_content
      t.text       :query_content

      t.timestamps null: false
    end
  end
end
