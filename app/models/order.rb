class Order < ActiveRecord::Base
  EFFECTIVE_STATES = %w(payed completed unevaluate)

  def self.inherited(base)
    Order.class_eval do
      define_method(:"is_#{base.name.underscore}?") { type == base.name }
    end
    super
  end

  include AASM
  include Orderable
  include Numberable

  belongs_to :user
  belongs_to :express
  belongs_to :seller, class_name: "User"
  belongs_to :user_address
  has_many   :order_items
  has_many   :evaluations
  has_many   :preferential_measures, through: :order_items
  has_many   :preferentials_seller_bonuses, through: :order_items
  has_many   :preferentials_privileges, through: :order_items
  belongs_to :order_charge, autosave: true
  has_many   :divide_incomes
  has_many   :selling_incomes
  has_many   :sharing_incomes, through: :order_items
  has_many   :order_item_refunds, through: :order_items

  accepts_nested_attributes_for :order_items

  validates :type, inclusion: { in: ['OrdinaryOrder', 'ServiceOrder','AgencyOrder', 'DishesOrder'] }
  validates :user_id, :seller_id, presence: true
  validates_uniqueness_of :number, allow_blank: true

  scope :selled, -> { where("orders.state <> 0") }

  delegate :mobile, :regist_mobile, :identify, to: :user, prefix: :buyer
  delegate :mobile, :regist_mobile, :identify, to: :seller, prefix: true, allow: nil
  delegate :prepay_id, :prepay_id=, :prepay_id_expired_at, :prepay_id_expired_at=,
    :pay_serial_number, :pay_serial_number=, :payment, :payment_i18n, :paid_at,
    to: :order_charge, allow_nil: true

  scope :selled, -> { where("orders.state <> 0") }
  scope :have_paid, -> { where(state: [1, 3, 4, 6]) }
  scope :today, -> (date=Date.today) { have_paid.where(['DATE(orders.created_at) = ?', date]) }
  scope :week, -> (time=Time.now) { have_paid.where(created_at: time.beginning_of_week..time.end_of_week) }
  scope :month, -> (time=Time.now) { have_paid.where(created_at: time.beginning_of_month..time.end_of_month) }
  scope :commons, -> { where(type: %w(OrdinaryOrder AgencyOrder)) }

  after_create :invoke_privielge_calculator

  def after_completed
  end
  def after_payed
  end
  def after_close
  end
  def after_signed
  end

  def effective?
    EFFECTIVE_STATES.include?(state.to_s)
  end

  def total_privilege_amount
    @total_privilege_amount ||= preferentials_privileges.sum(:total_amount)
  end

  def seller_bonus
    @seller_bonus ||= preferentials_seller_bonuses.sum(:total_amount)
  end

  def order_charge
    super || build_order_charge
  end

  def paid?
    @paid ||= paid_at.present?
  end

  def check_paid
    return true if !unpay?

    if order_charge.paid?
      self.pay! if state == 'unpay'
      true
    else
      false
    end
  end

  def update_pay_amount
    update_column(:pay_amount, order_items.sum(:pay_amount) + ship_price)
  end

  def sharing_user
    @sharing_user ||= order_items.first.try(:sharing_node).try(:user)
  end

  def official_agent?
    return @is_official_agent unless @is_official_agent.nil?

    if seller_id != User.official_account.try(:id)
      return @is_official_agent = false
    end

    official_agent_product = Product.official_agent
    if official_agent_product.blank?
      return @is_official_agent = false
    end

    @is_official_agent = order_items.joins(:product).where(
      products: { id: official_agent_product.id }
    ).exists?
  end

  def available_pay?
    errors.add(:base, '已支付') unless unpay?
    errors.add(:base, '重复购买创客权') if official_agent? && user.is_agent?
    errors.empty?
  end

  private

  def invoke_privielge_calculator
    @preferential_calculator = PreferentialCalculator.new(
      buyer: user,
      preferential_items: order_items
    )
    @preferential_calculator.calculate_preferential_info
    @preferential_calculator.save_preferentials do |order_item|
      order_item.reset_payment_info
      order_item.changed? && order_item.save
    end
  end

  def generate_number
    time_stamp = (Time.now - Time.parse('2014-12-12')).to_i
    rand_num = ((self.user_id + rand(10000)) % 100000).to_s.rjust(5, '0')
    "#{time_stamp}#{rand_num}#{SecureRandom.hex(3).upcase}"
  end

end
