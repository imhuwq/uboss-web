require 'test_helper'
require 'agency_order'

class OrderDivideJobTest < ActiveJob::TestCase
  before :each do
    official_account = create(:user)
    User.stubs(:official_account).returns(official_account)
  end

  describe 'Order pay' do
    let(:order) { create(:order_with_item) }
    it 'should enqueued this job' do
      User.stubs(:official_account).returns(User.new)
      order.update(state: 'shiped')
      assert_enqueued_with(job: OrderDivideJob, args: [order]) do
        assert_equal true, order.sign!
      end
    end
  end

  it 'should raise error if not payed' do
    @order = create(:ordinary_order)

    assert_equal false, @order.payed?

    assert_raises OrderDivideJob::OrderNotSigned do
      OrderDivideJob.perform_now(@order)
    end
  end

  it 'should setup seller income' do
    @order = create(:order_with_item, state: 'signed')

    @order.reload
    assert @order.pay_amount > 0
    assert_equal 0, @order.income

    OrderDivideJob.perform_now(@order)

    assert_equal true, @order.reload.income > 0
  end

  describe 'With sharing code' do
    let(:buy_amount) { 2 }

    it 'should only reward 1 user' do
      product = create :product_with_1sharing
      product_inventory = product.seling_inventories.first
      sharing_reward_lv1 = product_inventory.share_amount_lv_1

      assert sharing_reward_lv1 > 0

      level1_node = create(:sharing_node, product: product)
      level2_node = create(:sharing_node, product: product, parent: level1_node)

      buyer = create(:user)

      @order = create(:ordinary_order,
                      user: buyer,
                      order_items_attributes: [{
                        product: product,
                        product_inventory: product_inventory,
                        user: buyer,
                        amount: buy_amount,
                        sharing_node: level2_node
                      }],
                      state: 'signed'
                     )

      OrderDivideJob.perform_now(@order.reload)

      assert_equal 0, level1_node.user.reload.income.to_f
      assert_equal sharing_reward_lv1 * buy_amount, level2_node.user.reload.income
    end

    it 'should not reward user if money refund approved' do
      product = create :product_with_1sharing
      product_inventory = product.seling_inventories.first
      product_inventory.update(price: 100)
      sharing_reward_lv1 = product_inventory.share_amount_lv_1

      assert sharing_reward_lv1 > 0

      level1_node = create(:sharing_node, product: product)
      level2_node = create(:sharing_node, product: product, parent: level1_node)

      buyer = create(:user)

      @order = create(:ordinary_order,
                      user: buyer,
                      order_items_attributes: [{
                        product: product,
                        product_inventory: product_inventory,
                        user: buyer,
                        amount: buy_amount,
                        sharing_node: level2_node
                      }],
                      state: 'signed'
                     )

      refund = create(:order_item_refund, money: 10, order_item: @order.order_items.first)
      refund.approve!
      @order.update_column(:pay_amount, 200)
      OrderDivideJob.perform_now(@order.reload)

      assert_equal 0, @order.sharing_incomes.count
      assert_equal 4.75, @order.divide_incomes.sum(:amount)
      assert_equal 185.25, @order.reload.income
    end

    it 'should reward sharing user success & divide to agent and citymm' do
      agent = create(:agent_user)
      seller = create(:seller_user, agent: agent)
      city_manager = create(:city_manager)
      create(:personal_authentication, user: seller, status: 'pass', )
      city_manager_user = city_manager.user

      product = create :product_with_3sharing, user: seller
      product_inventory = product.seling_inventories.first

      sharing_reward_lv1 = product_inventory.share_amount_lv_1
      sharing_reward_lv2 = product_inventory.share_amount_lv_2
      sharing_reward_lv3 = product_inventory.share_amount_lv_3

      assert sharing_reward_lv1 > 0
      assert sharing_reward_lv2 > 0
      assert sharing_reward_lv3 > 0

      level1_node = create(:sharing_node, product: product)
      level2_node = create(:sharing_node, product: product, parent: level1_node)
      level3_node = create(:sharing_node, product: product, parent: level2_node)
      level4_node = create(:sharing_node, product: product, parent: level3_node)
      level4_node_user = level4_node.user
      create(:privilege_card, user: level4_node_user, seller: product.user)
      level4_node_user.update privilege_rate: 50

      assert level2_node.user.income == 0
      assert level3_node.user.income == 0
      assert level4_node.user.income == 0
      assert agent.income == 0
      assert seller.income == 0

      buyer = create(:user)
      @order = create(:ordinary_order,
                      user: buyer,
                      seller: seller,
                      order_items_attributes: [{
                        product: product,
                        product_inventory: product_inventory,
                        user: buyer,
                        amount: buy_amount,
                        sharing_node: level4_node
                      }],
                      state: 'signed'
                     )

      @order.update(paid_amount: @order.reload.pay_amount)
      OrderDivideJob.perform_now(@order.reload)

      assert_equal 0, level1_node.user.reload.income.to_f
      assert_equal sharing_reward_lv3 * buy_amount, level2_node.user.reload.income
      assert_equal sharing_reward_lv2 * buy_amount, level3_node.user.reload.income
      assert_equal sharing_reward_lv1 * buy_amount * 0.5, level4_node.user.reload.income
      assert seller.reload.income > 0, 'Seller get selling income'
      assert agent.reload.income > 0, 'Agent get deviding income'
      assert city_manager_user.reload.income > 0, 'CityManager get deviding income'
      assert_equal(
        @order.paid_amount,
        level2_node.user.income + level3_node.user.income + level4_node.user.income + seller.income + city_manager_user.income + agent.income + User.official_account.reload.income
      )
    end

    it 'reward user using nestest inventory version' do
      seller = create(:seller_user)

      product = create :product_with_3sharing, user: seller
      product_inventory = product.seling_inventories.first

      sharing_reward_lv1 = product_inventory.share_amount_lv_1
      sharing_reward_lv2 = product_inventory.share_amount_lv_2
      sharing_reward_lv3 = product_inventory.share_amount_lv_3

      assert sharing_reward_lv1 > 0
      assert sharing_reward_lv2 > 0
      assert sharing_reward_lv3 > 0

      level1_node = create(:sharing_node, product: product)
      level2_node = create(:sharing_node, product: product, parent: level1_node)

      assert level2_node.user.income == 0
      assert seller.income == 0

      buyer = create(:user)
      @order = create(:ordinary_order,
                      user: buyer,
                      seller: seller,
                      order_items_attributes: [{
                        product: product,
                        product_inventory: product_inventory,
                        user: buyer,
                        amount: buy_amount,
                        sharing_node: level2_node
                      }],
                      state: 'shiped'
                     )
      create(:paid_order_charge, orders: [@order])
      @order.update(paid_amount: @order.reload.pay_amount)
      product_inventory.update( price: 20000, share_amount_total: 1000, share_amount_lv_1: 800, privilege_amount: 200)
      product_inventory.update( price: 30000, share_amount_total: 2000, share_amount_lv_1: 1600, privilege_amount: 400)
      product_inventory.update( price: 40000, share_amount_total: 3000, share_amount_lv_1: 2400, privilege_amount: 600)
      @order.update_columns(state: 4)
      OrderDivideJob.perform_now(@order.reload)

      assert_equal (sharing_reward_lv2 * buy_amount).to_f, level1_node.user.reload.income.to_f
      assert_equal sharing_reward_lv1 * buy_amount, level2_node.user.reload.income
      assert seller.reload.income > 0, 'Seller get selling income'
      assert_equal(
        @order.paid_amount,
        level1_node.user.income + level2_node.user.income + seller.income + User.official_account.reload.income
      )
    end

    it 'divide amount should only be take 2 decimal' do
      official_account = create_or_find_official_account
      agent = create(:agent_user)
      seller = create(:seller_user, agent: agent)

      @order = create(:ordinary_order, seller: seller, state: 'signed')
      @order.stubs(:pay_amount).returns(BigDecimal('11.11'))
      @order.update_columns(paid_amount: 11.11)

      OrderDivideJob.perform_now(@order.reload)

      assert_equal 0.27, agent.reload.income
      assert_equal 0.27, official_account.reload.income
      assert_equal 10.57, seller.reload.income
    end

  end

end
