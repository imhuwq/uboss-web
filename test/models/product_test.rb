require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  test 'total_sells' do
    buyer = create(:user)
    product = create :product_with_1sharing
    product_inventory = create(:product_inventory, product: product)
    level1_node = create(:sharing_node, product: product)
    level2_node = create(:sharing_node, product: product, parent: level1_node)
    10.times do
      create(:order,
             user: buyer,
             order_items_attributes: [{
               product: product,
               product_inventory: product_inventory,
               user: buyer,
               amount: 2,
               sharing_node: level2_node
             }],
             state: 'signed'
            )
    end
    assert_equal(20, product.total_sells)
  end

  test 'product_inventories_attributes=' do
    product_inventories_attributes = {
      '0' => { price: 100, count: 100, sku_attributes: { size: 'x', color: 'red' } },
      '1' => { price: 100, count: 100, sku_attributes: { size: 'm', color: 'red' } },
      '2' => { price: 100, count: 100, sku_attributes: { size: 'l', color: 'red' } },
    }

    product = create(:product, product_inventories_attributes: product_inventories_attributes)

    assert_equal 3, product.product_inventories.count

    product_inventories_attributes_with_update = [
      { price: 200, count: 100, sku_attributes: { size: 'l', color: 'red' } },
      { price: 100, count: 100, sku_attributes: { size: 'xl', color: 'red' } },
      { price: 100, count: 100, sku_attributes: { size: 'xxl', color: 'red' } }
    ]

    product.update(product_inventories_attributes: product_inventories_attributes_with_update)

    assert_equal 5, product.product_inventories.count
    assert_equal 3, product.product_inventories.saling.count
    assert_equal 200, product.product_inventories.find_by(sku_attributes: [{ size: 'l', color: 'red' }]).price
    assert_not product.product_inventories.find_by(sku_attributes: [{ size: 'x', color: 'red' }]).saling

    product_inventories_attributes_with_update = [
      { price: 200, count: 100, sku_attributes: { size: 'x', color: 'red' } }
    ]
    product.update(product_inventories_attributes: product_inventories_attributes_with_update)
    assert_equal 1, product.product_inventories.saling.count
    assert product.product_inventories.find_by(sku_attributes: [{ size: 'x', color: 'red' }]).saling

    assert_equal 5, product.product_inventories.count
  end

end
