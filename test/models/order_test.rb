require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test 'order closed should recover sku strock' do
    buy_amount = 10
    product_inventory = create(:product_inventory, product: create(:ordinary_product))
    buyer = create(:user)

    order = create(:ordinary_order,

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

  test '多个商品运费满减' do
    items = []
    items.push(item1 = create(:order_item))
    items.push(item2 = create(:order_item))
    items.push(item3 = create(:order_item))
    #item1 统一运费, 满20元包邮
    p1 = item1.product
    p1.update(full_cut: true, full_cut_number: 20, full_cut_unit: 1)
    item1.amount = 10
    item1.save

    #item2 统一运费, 满2件包邮
    p2 = item2.product
    p2.update(full_cut: true, full_cut_number: 2, full_cut_unit: 0)
    item2.amount = 2
    item2.save

    #item2 模板
    p3 = item3.product
    p3.update(full_cut: true, full_cut_number: 2, full_cut_unit: 0, transportation_way: 2, carriage_template_id: 1)
    item3.amount = 2
    item3.save
    user_address = create(:user_address)
    price = OrdinaryOrder.calculate_ship_price(items, user_address)
    assert_equal price , 0.0
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
      order.update_column(:state, OrdinaryOrder.states[:shiped])
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
