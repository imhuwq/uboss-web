class Order < ActiveRecord::Base
  attr_accessor :type if not instance_method_already_implemented?(:type)  # TODO 暂时添加虚拟字段, 防止和团购代码冲突

  include AASM
  include Orderable
  include Numberable

  belongs_to :user
  belongs_to :express
  belongs_to :seller, class_name: "User"
  belongs_to :user_address
  has_many   :order_items
  has_many   :preferential_measures, through: :order_items
  has_many   :preferentials_seller_bonuses, through: :order_items
  has_many   :preferentials_privileges, through: :order_items
  belongs_to :order_charge, autosave: true
  has_many   :divide_incomes
  has_many   :selling_incomes
  has_many   :sharing_incomes, through: :order_items
  has_many   :order_item_refunds, through: :order_items

  accepts_nested_attributes_for :order_items

  validates :user_id, :user_address_id, :seller_id, presence: true
  validates_uniqueness_of :number, allow_blank: true

  delegate :mobile, :regist_mobile, :identify,
    to: :user, prefix: :buyer
  delegate :prepay_id, :prepay_id=, :prepay_id_expired_at, :prepay_id_expired_at=,
    :pay_serial_number, :pay_serial_number=, :payment, :payment_i18n, :paid_at,
    to: :order_charge, allow_nil: true

  scope :selled, -> { where("orders.state <> 0") }
  scope :with_refunds, -> {
    joins(order_items: :order_item_refunds).uniq
  }

  scope :have_paid, -> { where(state: [1, 3, 4, 6]) }
  scope :today, -> (date=Date.today) { have_paid.where(['DATE(orders.created_at) = ?', date]) }
  scope :week, -> (time=Time.now) { have_paid.where(created_at: time.beginning_of_week..time.end_of_week) }
  scope :month, -> (time=Time.now) { have_paid.where(created_at: time.beginning_of_month..time.end_of_month) }

  before_create :set_info_by_user_address, :set_ship_price
  after_create :invoke_privielge_calculator

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5, completed: 6 }

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unpay
    state :payed, after_enter: [:update_stock_item, :create_purchase_order]
    state :shiped, after_enter: [:fill_shiped_at, :close_order_item_refund_before_shiping]
    state :signed, after_enter: [:fill_signed_at, :active_privilege_card, :close_refunds_before_signed]
    state :completed, after_enter: :fill_completed_at
    state :closed, after_enter: :recover_product_stock

    event :pay, after_commit: :invoke_order_payed_processes do
      transitions from: :unpay, to: :payed
    end
    event :ship do
      transitions from: :payed, to: :shiped do
        guard do
          can_be_ship?
        end
      end
    end
    event :sign, after_commit: :call_order_complete_handler do
      transitions from: :shiped, to: :signed
      transitions from: :payed, to: :signed, guards: :single_official_agent?
    end
    event :close do
      transitions from: :unpay, to: :closed
    end
    event :complete do
      transitions from: :signed, to: :completed
    end
  end

  def has_payed?
    Order.states[self.state] >= 1 && Order.states[self.state] != 5
  end

  def has_refund?
    order_items.joins(:order_item_refunds).exists?
  end

  class << self
    def valid_items(cart_items, province)
      if province.present?
        province = ChinaCity.get(province)
        cart_items.inject([]){ |items, cart_item| valid_to_sales?(cart_item.product_inventory.product, province) ? items << cart_item : items  }
      else
        cart_items
      end
    end

    def valid_to_sales?(product, province)   # province = "北京市"
      if province.present? && product.transportation_way == 2 && product.carriage_template
        different_areas = product.carriage_template.different_areas
        different_areas.joins(:regions).where(regions: {name: province}).first.present? ? true : false
      else
        true
      end
    end

    #items1 是统一邮费, items2 是运费模板, user_address: 寄货地址
    def total_ship_price(items1, items2, user_address)
      return 0.0 if items1.blank? && items2.blank?
      begin
        province = ChinaCity.get(user_address.province)
      rescue
        return 0.0
      end
      max_traffic = max_traffic_expense(items1)
      carriage_template_group, items_count = uniq_carriage_template(items2)
      different_areas = find_all_different_areas(carriage_template_group, province)

      max_carriage_expense = (different_areas.sort_by{ |area| [-area.carriage, area.extend_carriage] }.try(:first) || 0)

      if max_traffic.to_f >= max_carriage_expense.try(:carriage).to_f && max_carriage_expense.try(:extend_carriage).to_f >= 0
        ship_price = max_traffic
        different_areas.each_with_index do |area, index|
          ship_price += carriage_way(area, items_count[index])
        end
      else
        ship_price = max_traffic + max_carriage_expense.carriage
        different_areas.each_with_index do |area, index|
          if area == max_carriage_expense
            balance = items_count[index] - max_carriage_expense.first_item
            ship_price += carriage_way(area, balance) if balance > 0
            next
          end
          ship_price += carriage_way(area, items_count[index])
        end
      end

      ship_price || 0.0
    end

    def carriage_way(different_area, count)
      extend_price = count.to_f / different_area.extend_item.to_f
      different_area.extend_carriage * ( extend_price < 1 ? 1 : extend_price.round )
    end

    def find_template_by_address(carriage_template, address)
      different_areas = carriage_template.different_areas
      different_areas.joins(:regions).where(regions: {name: address}).try(:first)
    end

    def find_all_different_areas(items, province)
      different_areas = []
      items.each do |item|
        different_areas.push(find_template_by_address(item.product_inventory.carriage_template, province))
      end
      different_areas.compact
    end

    #{ 0 => '包邮', 1 => '统一邮费', 2 => '运费模板' }
    def unify_transportation_way(items)
      items.select{ |item| item.product_inventory.transportation_way == 1 }
    end

    def template_transportation_way(items)
      items.select{ |item| item.product_inventory.transportation_way == 2 }
    end

    def max_traffic_expense(items1)
      return 0 if items1.blank?
      items1.map { |item| item.product_inventory.product.traffic_expense }.max
    end

    def carriage_template_group_by(items2)
      items2.group_by{ |item| item.product_inventory.carriage_template_id }
    end

    def uniq_carriage_template(items2)
      uniq_items, items_count = [], []
      return [uniq_items, items_count] if items2.blank?
      carriage_template_group_by(items2).each do |carriage_template_id, items|
        items_count.push(items.sum{ |item| item.count })
        uniq_items.push(items.first)
      end
      [uniq_items, items_count]
    end

    def calculate_ship_price(cart_items, user_address)
      cart_items = meet_full_cut?(cart_items)

      items1 = cart_items.select{ |item| item.product_inventory.transportation_way == 1 }
      items2 = cart_items.select{ |item| item.product_inventory.transportation_way == 2 }

      total_ship_price(items1, items2, user_address)
    end

    #运费满减
    def meet_full_cut?(cart_items)
      full_cut_items = cart_items.select{ |item| item.product_inventory.full_cut }
      cut_items = []

      full_cut_items.each do |item|
        if Product::FullCut[item.product_inventory.full_cut_unit] == '件'
          cut_items.push(item) if item.count >= item.product_inventory.full_cut_number
        else
          cut_items.push(item) if (item.count * item.product_inventory.price) >= item.product_inventory.full_cut_number
        end
      end

      return cart_items - cut_items
    end


    def sum_ship_price(cart_items, user_address)
      sum = 0.0
      CartItem.group_by_seller(cart_items).each do |seller, cart_item|
        sum += calculate_ship_price(cart_item, user_address)
      end
      sum
    end
  end

  def ship_info
    "#{address} #{username}(收)"
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

  def single_official_agent?
    order_items.size == 1 && official_agent?
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

  def can_be_ship?
    if !self.seller.default_get_address.present?
      errors[:base] << "请设置默认退货地址"
      false
    else
      true
    end
  end

  private

  def invoke_privielge_calculator
    @preferential_calculator ||= PreferentialCalculator.new(
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

  def fill_shiped_at
    update_column(:shiped_at, Time.now)
  end

  def update_stock_item
    order_items.each {|item| StockMovement.unstock(item.product_inventory, quantity) }
  end

  def fill_signed_at
    update_column(:signed_at, Time.now)
  end

  def fill_completed_at
    update_column(:completed_at, Time.now)
  end

  def set_info_by_user_address
    self.address = "#{user_address}"
    self.mobile = user_address.mobile
    self.username = user_address.username
  end

  def set_ship_price
    self.ship_price = calculate_ship_price
  end

  def calculate_ship_price
    cart_items = Order.meet_full_cut?(order_items)

    items1 = cart_items.select{ |item| item.product_inventory.transportation_way == 1 }
    items2 = cart_items.select{ |item| item.product_inventory.transportation_way == 2 }

    Order.total_ship_price(items1, items2, user_address)
  end

  def call_order_complete_handler
    OrderDivideJob.set(wait: 5.seconds).perform_later(self)
  end

  def recover_product_stock
    order_items.each { |order_item| order_item.recover_product_stock }
  end

  def active_privilege_card
    order_items.each(&:active_privilege_card)
  end

  def invoke_order_payed_processes
    # 在work 中判断订单是否是创客权订单
    OfficialAgentOrderJob.set(wait: 5.seconds).perform_later(self)
    OrderPayedJob.set(wait: 2.seconds).perform_later(self)
  end

  def close_order_item_refund_before_shiping
    order_items.joins(:order_item_refunds).uniq.each do |item|
      refund = item.last_refund
      if refund.may_close? && refund.close!
        refund.refund_messages.create(
          user_type: '卖家',
          user_id: seller_id,
          message: '商家选择发货，退款申请关闭',
          action: '退款关闭'
        )
      end
    end
  end

  def close_refunds_before_signed
    order_items.joins(:order_item_refunds).uniq.each do |item|
      refund = item.last_refund
      if refund.may_close? && refund.close!
        refund.refund_messages.create(
          user_type: '买家',
          user_id: user_id,
          message: '买家确认收货，退款申请关闭',
          action: '退款关闭'
        )
      end
    end
  end

  def create_purchase_order
    PurchaseOrder.create(order: self, seller_id: user_id, supplier_id: 1) if order.type == 'FenxiaoOrder' # TODO
  end

end
