class Evaluation < ActiveRecord::Base
  validates_presence_of :order_item_id

  belongs_to :sharing_node
  belongs_to :order_item
  belongs_to :user, foreign_key: :buyer_id
  belongs_to :product

  before_save :relate_attrs
  after_save :set_order_item_evaluation_id
  after_create :count_evaluation, :create_or_attach_sharing_node

  enum status: { good: 1, normal: 2,bad: 3}

  def relate_attrs # 取出order_item的值并斌给Evaluation中对应的属性
    if order_item
      self.buyer_id = order_item.user_id
      self.sharer_id = order_item.sharing_node_id
      self.product_id = order_item.product_id
    end
  end

  def count_evaluation # 计算出用户和产品的好、中、差评论数并保存
    if self.sharer_id
      user_info_id = User.find(self.sharer_id).user_info.id
      case self.status
      when 'good'
        UserInfo.update_counters user_info_id, good: 1
        Product.update_counters self.product_id, good: 1
      when 'normal'
        UserInfo.update_counters user_info_id, normal: 1
        Product.update_counters self.product_id, normal: 1
      when 'bad'
        UserInfo.update_counters user_info_id, normal: 1
        Product.update_counters self.product_id, normal: 1
      end
    end
  end

  def set_order_item_evaluation_id # 找到关联的OrderItem并修改他的evaluation_id
    OrderItem.find_by_id(order_item_id).update_attribute(:evaluation_id, id)
  end

  def self.sharer_good_reputation(sharer_id) # 分享者好评数
    # evaluation = Evaluation.where(sharer_id: sharer_id)
    # good = evaluation.where(status: 1).count
    User.find_by_id(sharer_id).user_info.good
  end

  def self.sharer_good_reputation_rate(sharer_id) # 分享者好评率
    # evaluation = Evaluation.where(sharer_id: sharer_id)
    # total = evaluation.count
    # if total != 0
    #   good = evaluation.where(status: 1).count
    #   rate = "#{'%.2f' % (good/total.try(:to_f)*100)}%"
    # else
    #   "100.00%"
    # end
    user_info = User.find_by_id(sharer_id).user_info
    rate = user_info.good_evaluation/(user_info.good_evaluation + user_info.normal_evaluation + user_info.bad_evaluation) rescue 1
    "#{'%.2f' % (rate.try(:to_f)*100)}%"
  end

  def self.product_good_reputation(product_id) # 商品好评数
    # evaluation = Evaluation.where(product_id: product_id)
    # good_evaluation = evaluation.where(status: 1).count
    Product.find_by_id(product_id).good_evaluation
  end

  def self.product_good_reputation_rate(product_id) # 商品好评率
    # evaluation = Evaluation.where(product_id: product_id)
    # total = evaluation.count
    # if total != 0
    #   good = evaluation.where(status: 1).count
    #   rate = "#{'%.2f' % (good/total.try(:to_f)*100)}%"
    # else
    #   "100.00%"
    # end
    product = Product.find_by_id(product_id)
    rate = product.good_evaluation/(product.good_evaluation + product.normal_evaluation + product.bad_evaluation) rescue 1
    "#{'%.2f' % (rate.try(:to_f)*100)}%"
  end

  private

  def create_or_attach_sharing_node
    node_parent_id = order_item.sharing_node_id
    node = SharingNode.find_or_create_by(
      user_id: buyer_id, product_id: product_id, parent_id: node_parent_id)
    self.update_column(:sharing_node_id, node.id)
  end
end
