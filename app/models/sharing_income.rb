class SharingIncome < ActiveRecord::Base
  include UserIncomeable
  include Orderable
  include Numberable

  belongs_to :user
  belongs_to :seller, class_name: 'User'
  belongs_to :order_item
  belongs_to :sharing_node

  validates :user_id, :seller_id, :order_item_id, :sharing_node_id, presence: true
  validates :level, inclusion: { in: 1..3 }
  validates_numericality_of :amount, greater_than: 0

  delegate :nickname, :regist_mobile, :identify, to: :user, prefix: true
  delegate :product_name, :product, to: :order_item
  delegate :order, to: :order_item

  after_create :increase_user_income, :record_trade, :send_income_arrive_template_msg

  private

  def generate_number
    "#{(Time.now - Time.parse('1999-12-12')).to_i}#{rand(100000).to_s.rjust(5,'0')}#{SecureRandom.hex(3).upcase}"
  end

  def increase_user_income
    UserInfo.update_counters(user.user_info.id, user_incomes)
  end

  def user_incomes
    return @user_incomes if @user_incomes.present?
    @user_incomes = { income: amount }
  end

  def record_trade
    Transaction.create!(
      user: user,
      source: self,
      adjust_amount: amount,
      current_amount: user.income,
      trade_type: 'sharing'
    )
  end

  def send_income_arrive_template_msg
    WxTemplateMsg.income_arrive_notify_msg_to_buyer(user.weixin_openid, self) if user && user.weixin_openid.present?
  end
end
