require 'test_helper'

class ProductInventoryTest < ActiveSupport::TestCase

  test '#should create new version if order payed but not signed' do
    product = create :product
    product_inventory = product.seling_inventories.first

    assert_equal 0, product_inventory.versions.size

    create(
      :order,
      state: 'payed',
      order_items_attributes: [
        {
          product: product,
          product_inventory: product_inventory,
          user: product.user,
          amount: 1
        }
      ]
    )

    product_inventory.update(price: product_inventory.price + 100)
    assert_equal 1, product_inventory.versions.size
  end

end
