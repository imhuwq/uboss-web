class Order < ActiveRecord::Base

  include AASM
  include Orderable
  include Numberable

  belongs_to :user
  belongs_to :express
  belongs_to :seller, class_name: "User"
  belongs_to :user_address
  has_many   :order_items
  belongs_to :order_charge, autosave: true
  has_many   :divide_incomes
  has_many   :selling_incomes
  has_many   :sharing_incomes, through: :order_items

  accepts_nested_attributes_for :order_items

  validates :user_id, :user_address_id, :seller_id, presence: true
  validates_uniqueness_of :number, allow_blank: true

  delegate :mobile, :regist_mobile, :identify,
    to: :user, prefix: :buyer
  delegate :prepay_id, :prepay_id=, :prepay_id_expired_at, :prepay_id_expired_at=,
    :pay_serial_number, :pay_serial_number=, :payment, :payment_i18n, :paid_at,
    to: :order_charge, allow_nil: true

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5, completed: 6 }

  scope :selled, -> { where("orders.state <> 0") }

  before_create :set_info_by_user_address, :set_ship_price

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unpay
    state :payed, after_enter: [:create_privilege_card_if_none, :send_payed_sms_to_seller]
    state :shiped, after_enter: :fill_shiped_at
    state :signed, after_enter: [:fill_signed_at, :active_privilege_card]
    state :completed, after_enter: :fill_completed_at
    state :closed, after_enter: :recover_product_stock

    event :pay, after_commit: :invoke_official_agent_order_process do
      transitions from: :unpay, to: :payed
    end
    event :ship do
      transitions from: :payed, to: :shiped
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
    Order.states[self.state] >= 1
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
      different_area.extend_carriage * ( extend_price < 1 ? 1 : extend_price )
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
      items1 = cart_items.select{ |item| item.product_inventory.transportation_way == 1 }
      items2 = cart_items.select{ |item| item.product_inventory.transportation_way == 2 }

      total_ship_price(items1, items2, user_address)
    end

    def sum_ship_price(cart_items, user_address)
      sum = 0.0
      CartItem.group_by_seller(cart_items).each do |seller, cart_item|
        sum += calculate_ship_price(cart_item, user_address)
      end
      sum
    end
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
    @sharing_user ||= order_items.first.sharing_node.try(:user)
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
    if !User.find(self.user_id).default_get_address.present?
      errors[:base] << "请设置默认退货地址"
      return false
    end
  end

  private

  def generate_number
    time_stamp = (Time.now - Time.parse('2014-12-12')).to_i
    rand_num = ((self.user_id + rand(10000)) % 100000).to_s.rjust(5, '0')
    "#{time_stamp}#{rand_num}#{SecureRandom.hex(3).upcase}"
  end

  def fill_shiped_at
    update_column(:shiped_at, Time.now)
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
    items1 = order_items.select{ |item| item.product_inventory.transportation_way == 1 }
    items2 = order_items.select{ |item| item.product_inventory.transportation_way == 2 }

    Order.total_ship_price(items1, items2, user_address)
  end

  def call_order_complete_handler
    OrderDivideJob.set(wait: 5.seconds).perform_later(self)
  end

  def recover_product_stock
    order_items.each { |order_item| order_item.recover_product_stock }
  end

  def create_privilege_card_if_none
    order_items.each(&:create_privilege_card_if_none)
  end

  def send_payed_sms_to_seller
    if seller
      PostMan.delay.send_sms(seller.login, {name: seller.identify}, 968369)
    end
  end

  def active_privilege_card
    order_items.each(&:active_privilege_card)
  end

  # 在work 中判断订单是否是创客权订单
  def invoke_official_agent_order_process
    OfficialAgentOrderJob.set(wait: 5.seconds).perform_later(self)
  end

end
