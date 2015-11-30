require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test 'order closed should recover sku strock' do
    buy_amount = 10
    product_inventory = create(:product_inventory, product: create(:product))
    buyer = create(:user)

    order = create(:order,
                    user: buyer,
                    order_items_attributes: [{
                      product: product_inventory.product,
                      product_inventory: product_inventory,
                      user: buyer,
                      amount: buy_amount
                    }]
                   )

    assert_equal 90, product_inventory.reload.count

    order.close!

    assert_equal 100, product_inventory.reload.count
  end

  test 'should auto close refund if ship or signed order' do
    order = create(:order_with_item, state: 'payed')
    order_item = order.reload.order_items.first
    refund = create(:order_item_refund, order_item: order_item)

    assert_equal 'pending', refund.aasm_state

    order.stubs(:can_be_ship?).returns(true)
    assert order.ship!, 'ship order fail'
    assert_equal 'closed', refund.reload.aasm_state

    refund = create(:order_item_refund, order_item: order_item.reload)
    assert_equal 'pending', refund.aasm_state
    assert order.sign!, 'sign order fail'
    assert_equal 'closed', refund.reload.aasm_state

    [:declined, :completed_express_number, :decline_received, :applied_uboss].each do |state|
      # reset situation
      order.update_column(:state, Order.states[:shiped])
      refund.update_column(:aasm_state, state.to_s)

      assert_equal state.to_s, refund.aasm_state
      assert order.sign!, 'sign order fail'
      assert_equal 'closed', refund.reload.aasm_state
    end
  end

  #describe '运费计算' do
    #it '单个物品包邮' do
    #end

    #it '单个物品统一运费' do
    #end

    #it '含有包邮和统一运费' do
    #end

    #it '含有包邮和模板' do
    #end

    #it '含有统一运费和模板' do
    #end

    #it '含有包邮, 统一, 模板' do
    #end
  #end

  #describe '单个物品模板' do
    #it '件数大于首费情况' do
    #end

    #it '件数小于首费情况' do
    #end
  #end
end
