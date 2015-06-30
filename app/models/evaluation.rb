class Evaluation < ActiveRecord::Base
  validates_presence_of :order_item_id

  belongs_to :order_item

  has_one    :sharing_node

  before_save :relate_attrs
  after_save :set_order_item_evaluation_id

  def relate_attrs # 取出order_item的值并斌给Evaluation中对应的属性
    order_item = OrderItem.find_by_id(order_item_id)
    if order_item.present?
      self.buyer_id = order_item.user_id
      self.sharer_id = order_item.sharing_node.try(:user_id)
      self.product_id = order_item.product_id
    end
  end

  def set_order_item_evaluation_id # 找到关联的OrderItem并修改他的evaluation_id
    OrderItem.find_by_id(order_item_id).update_attribute(:evaluation_id, id)
  end

  def self.sharer_good_reputation(sharer_id) # 分享者好评数
    evaluation = Evaluation.where(sharer_id: sharer_id)
    good = evaluation.where(status: 1).count
  end

  def self.sharer_good_reputation_rate(sharer_id) # 分享者好评率
    evaluation = Evaluation.where(sharer_id: sharer_id)
    total = evaluation.count
    if total != 0
      good = evaluation.where(status: 1).count
      rate = "#{'%.2f' % (good/total.try(:to_f)*100)}%"
    else
      "100.00%"
    end
  end

  def self.product_good_reputation(product_id) # 商品好评数
    evaluation = Evaluation.where(product_id: product_id)
    good = evaluation.where(status: 1).count
  end

  def self.product_good_reputation_rate(product_id) # 商品好评率
    evaluation = Evaluation.where(product_id: product_id)
    total = evaluation.count
    if total != 0
      good = evaluation.where(status: 1).count
      rate = "#{'%.2f' % (good/total.try(:to_f)*100)}%"
    else
      "100.00%"
    end
  end
end
