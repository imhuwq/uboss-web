require 'test_helper'

class OrderDivideJobTest < ActiveJob::TestCase
  before :each do
    official_account = create(:user)
    User.stubs(:official_account).returns(official_account)
  end

  describe 'Order pay' do
    let(:order) { create(:order_with_item) }
    it 'should enqueued this job' do
      assert_enqueued_jobs 0
      User.stubs(:official_account).returns(User.new)
      order.update(state: 'shiped')
      assert_enqueued_with(job: OrderDivideJob, args: [order]) do
        assert_equal true, order.sign!
      end
      assert_enqueued_jobs 1
    end
  end

  it 'should raise error if not payed' do
    @order = create(:order)

    assert_equal false, @order.payed?

    assert_equal false, OrderDivideJob.perform_now(@order)
    #assert_raises OrderDivideJob::OrderNotPayed do
      #OrderDivideJob.perform_now(@order)
    #end
  end

  it 'should setup seller income' do
    @order = create(:order_with_item, state: 'signed')

    assert_equal 0, @order.income

    OrderDivideJob.perform_now(@order)

    assert_equal true, @order.reload.income > 0
  end

  describe 'With sharing code' do
    let(:buy_amount) { 2 }

    it 'should only reward 1 user' do
      product = create :product_with_1sharing
      product_inventory = create(:product_inventory, product: product)
      sharing_reward_lv1 = product.share_amount_lv_1

      level1_node = create(:sharing_node, product: product)
      level2_node = create(:sharing_node, product: product, parent: level1_node)

      buyer = create(:user)

      @order = create(:order,
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

      assert_equal 0, level1_node.user.income.to_f
      assert_equal sharing_reward_lv1 * buy_amount, level2_node.user.income
    end

    it 'should reward sharing user success' do
      product = create :product_with_3sharing
      product_inventory = create(:product_inventory, product: product)

      sharing_reward_lv1 = product.share_amount_lv_1
      sharing_reward_lv2 = product.share_amount_lv_2
      sharing_reward_lv3 = product.share_amount_lv_3

      level1_node = create(:sharing_node, product: product)
      level2_node = create(:sharing_node, product: product, parent: level1_node)
      level3_node = create(:sharing_node, product: product, parent: level2_node)
      level4_node = create(:sharing_node, product: product, parent: level3_node)

      buyer = create(:user)

      @order = create(:order,
                      user: buyer,
                      order_items_attributes: [{
                        product: product,
                        product_inventory: product_inventory,
                        user: buyer,
                        amount: buy_amount,
                        sharing_node: level4_node
                      }],
                      state: 'signed'
                     )

      OrderDivideJob.perform_now(@order.reload)

      assert_equal 0, level1_node.user.income.to_f
      assert_equal sharing_reward_lv3 * buy_amount, level2_node.user.income
      assert_equal sharing_reward_lv2 * buy_amount, level3_node.user.income
      assert_equal sharing_reward_lv1 * buy_amount, level4_node.user.income
    end
  end

end
