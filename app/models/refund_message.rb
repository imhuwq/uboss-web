class RefundMessage < ActiveRecord::Base
  belongs_to :order_item_refund
  belongs_to :refund_reason
  belongs_to :user
  has_many :asset_imgs, class_name: 'AssetImg', autosave: true, as: :resource

  DECLINE_REFUND  = ["已发货，请承担发货运费", "商品退回后才能退款", "买家已签收", "货物已在物流中", "其它"]
  DECLINE_RETURN  = ["退款金额不对，买家要求过高", "商品没问题，买家举证无效", "商品没问题，买家未举证", "申请时间已超过售后服务时限", "商品退回后才能退款", "其它"]
  DECLINE_RECEIVE = ["退回的商品影响二次销售", "已经协商好换货或维修", "买家退回的商品不是我店铺的", "买家填写的退货单号无记录", "未收到退货，快递还在途中", "买家擅自使用到付或平邮", "买家退回的商品不全"]

  default_scope {order("updated_at desc")}

  def self.all_messages(order_item)
    order_item.order_item_refunds.order('created_at DESC')
      .inject([]){ |messages, refund| messages += refund.refund_messages }
  end

  def image_files
    self.asset_imgs.map{ |img| img.avatar.file.filename }.join(',')
  end

end
