class SharingIncome < ActiveRecord::Base

  include Orderable

  USER_LEVEL_INCOME_MAPKEYS = [
    :income_level_one,
    :income_level_two,
    :income_level_thr
  ]

  belongs_to :user
  belongs_to :seller, class_name: 'User'
  belongs_to :order_item
  belongs_to :sharing_node

  validates :user_id, :seller_id, :order_item_id, :sharing_node_id, presence: true
  validates :level, inclusion: { in: 1..3 }
  validates_numericality_of :amount, greater_than: 0

  delegate :nickname, :regist_mobile, to: :user, prefix: true
  delegate :product_name, :product, to: :order_item
  delegate :order, to: :order_item

  before_create :set_number
  after_create :increase_user_income

  private

  def set_number
    loop do
      income_number =
        "#{(Time.now - Time.parse('2012-12-12')).to_i}#{rand(1000) % 10000}#{SecureRandom.hex(3).upcase}"
      unless SharingIncome.find_by(number: income_number)
        self.number = income_number and break
      end
    end
  end

  def increase_user_income
    UserInfo.update_counters(user.user_info.id, user_incomes)
  end

  def user_incomes
    return @user_incomes if @user_incomes.present?
    @user_incomes = { income: amount }
    @user_incomes.merge!(USER_LEVEL_INCOME_MAPKEYS[self.level - 1] => amount)
  end

end
