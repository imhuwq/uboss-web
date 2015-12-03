class Evaluation < ActiveRecord::Base

  belongs_to :sharing_node
  belongs_to :order_item
  belongs_to :user, foreign_key: :buyer_id
  belongs_to :product

  before_save :relate_attrs
  after_create :count_evaluation, :create_or_attach_sharing_node

  validates :order_item_id, :status, presence: true

  enum status: { worst: 1, bad: 2, good: 3, better: 4, best: 5 }

  def relate_attrs # 取出order_item的值并赋给Evaluation中对应的属性
    if order_item
      self.buyer_id = order_item.user_id
      self.sharer_id = order_item.sharing_node.try(:user_id)
      self.product_id = order_item.product_id
    end
  end

  def count_evaluation # 计算出用户和产品的好、中、差评论数并保存
    seller_user_info_id = Product.find(self.product_id).user.user_info.id
    evaluation_column = "#{self.status}_evaluation"

    UserInfo.update_counters(seller_user_info_id, evaluation_column => 1)
    Product.update_counters(self.product_id, evaluation_column => 1)
    if sharer_id.present? && sharer_user = User.find_by(id: self.sharer_id)
      sharer_user_info_id = sharer_user.user_info.id
      UserInfo.update_counters(sharer_user_info_id, evaluation_column => 1)
    end
  end

  def self.sharer_good_reputation(sharer_id) # 分享者好评数
    user_info = User.find_by_id(sharer_id).user_info
    user_info.good_evaluation.to_f +  user_info.better_evaluation.to_f + user_info.best_evaluation.to_f
  end

  def self.sharer_good_reputation_rate(user) # 分享者好评率
    user_info = user.user_info
    total = Evaluation.statuses.keys.inject(0) do |sum, statue|
      sum + user_info["#{statue}_evaluation"].to_i
    end
    if total > 0
      rate = (user_info.good_evaluation.to_f +
              user_info.best_evaluation.to_f +
              user_info.better_evaluation.to_f) / total
    else
      rate = 1
    end
    # FIXME 格式化的内容让helper去处理
    "#{'%.2f' % (rate.try(:to_f)*100)}%"
  end

  def self.product_good_reputation(product_id) # 商品好评数
    product = Product.find_by_id(product_id)
    (product.good_evaluation.to_f + product.best_evaluation.to_f + product.better_evaluation.to_f).try(:to_i)
  end

  def self.product_good_reputation_rate(product_id) # 商品好评率
    product = Product.find_by_id(product_id)
    total_evalution = product.good_evaluation.to_f + product.bad_evaluation.to_f + product.worst_evaluation.to_f + product.best_evaluation.to_f + product.better_evaluation.to_f
    good = product.good_evaluation.to_i + product.best_evaluation.to_i + product.better_evaluation.to_i
    rate = total_evalution > 0 ? good/total_evalution.to_f : 1
    "#{'%.2f' % (rate*100)}%"
  end

  private

  def create_or_attach_sharing_node
    node_parent_id = order_item.sharing_node_id
    node = SharingNode.find_or_create_by(
      user_id: buyer_id, product_id: product_id, parent_id: node_parent_id)
    self.update_column(:sharing_node_id, node.id)
  end
end
