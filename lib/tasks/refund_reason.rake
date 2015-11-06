namespace :reason do
  desc 'init refund reasons'
  task refund_reason: :environment do
    puts '开始添加退款理由'

    class_name = {refund: %w[不想要了, 拍错了/订单信息错误, 卖家缺货, 其它], receipted_refund: %w[拍错/效果不好/不喜欢, 商品腐烂/变质/有异物/水产死亡, 商品成分描述不符, 假冒品牌, 收到商品少件或破损, 生产日期/保质期与卖家承诺不符, 卖家发错货, 图片/产地/规格等描述不符, 其它], unreceipt_refund: %w[快递无跟踪记录, 未按约定时间发货, 快递一直未送到, 空包裹／少货, 多拍／拍错／不想要, 其它], after_sale_return_goods_and_refund: %w[退运费, 收到商品破损, 商品错发/漏发, 商品需要维修, 发票问题, 收到商品不符, 商品质量问题, 未收到货, 未按约定时间发货, 其它]}

    class_name.each do |key, values|
      values.each do |v|
        RefundReason.find_or_create_by(reason: v, reason_type: key)
      end
    end
    puts '退款理由添加成功!'
  end
end
