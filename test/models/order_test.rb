require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  describe 'order closed' do
    it 'should recover sku strock' do
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
    price = Order.calculate_ship_price(items, user_address)
    assert_equal price , 0.0
  end
end
