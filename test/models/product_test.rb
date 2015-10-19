require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  test 'set_default_share_rate_lv_3' do
    p = Product.new(has_share_lv: 3)
    p.set_share_rate
    assert_equal(Rails.application.secrets.product_sharing["level3"]["rate3"], p.share_rate_lv_3)
    assert_equal(Rails.application.secrets.product_sharing["level3"]["rate2"], p.share_rate_lv_2)
    assert_equal(Rails.application.secrets.product_sharing["level3"]["rate1"], p.share_rate_lv_1)
  end
  test 'set_default_share_rate_lv_2' do
    p = Product.new(has_share_lv: 2)
    p.set_share_rate
    assert_equal(0, p.share_rate_lv_3)
    assert_equal(Rails.application.secrets.product_sharing["level2"]["rate2"], p.share_rate_lv_2)
    assert_equal(Rails.application.secrets.product_sharing["level2"]["rate1"], p.share_rate_lv_1)
  end
  test 'set_default_share_rate_lv_1' do
    p = Product.new(has_share_lv: 1)
    p.set_share_rate
    assert_equal(0.0, p.share_rate_lv_3)
    assert_equal(0.0, p.share_rate_lv_2)
    assert_equal(Rails.application.secrets.product_sharing["level1"]["rate1"], p.share_rate_lv_1)
  end
  test 'set_share_rate_lv_1' do
    p = Product.new(has_share_lv: 1)
    p.set_share_rate(0.3, 0.2, 0.1)
    assert_equal(0.1, p.share_rate_lv_3)
    assert_equal(0.2, p.share_rate_lv_2)
    assert_equal(0.3, p.share_rate_lv_1)
  end

  test 'calculate_sharing_amount' do
    product_inventories_attributes = [
      { price: 300, count: 100, sku_attributes: { size: 'l', color: 'red' } },
      { price: 200, count: 100, sku_attributes: { size: 'm', color: 'red' } },
      { price: 100, count: 100, sku_attributes: { size: 'x', color: 'red' } }
    ]

    product = create(:product,
                     has_share_lv: 3,
                     share_rate_total: 10,
                     product_inventories_attributes: product_inventories_attributes
                    )

    product.update_columns(
      share_rate_lv_1: 0.4,
      share_rate_lv_2: 0.3,
      share_rate_lv_3: 0.2
    )
    product_inventories_share_amounts = product.seling_inventories.order('price DESC').
      pluck(:share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3, :privilege_amount).
      map do |inventory|
        inventory.map(&:to_i)
    end

    expect_share_amounts = product_inventories_attributes.map do |inventory|
      [
        (inventory[:price] * 0.04).to_i,
        (inventory[:price] * 0.03).to_i,
        (inventory[:price] * 0.02).to_i,
        (inventory[:price] * 0.01).to_i,
      ]
    end
    assert_equal expect_share_amounts, product_inventories_share_amounts


    product_inventories_attributes = [
      { price: 400, count: 100, sku_attributes: { size: 'l', color: 'red' } },
      { price: 200, count: 100, sku_attributes: { size: 'm', color: 'red' } },
      { price: 100, count: 100, sku_attributes: { size: 'x', color: 'red' } }
    ]
    product.reload
    product.update(
      share_rate_total: 20,
      product_inventories_attributes: product_inventories_attributes
    )

    product_inventories_share_amounts = product.seling_inventories.order('price DESC').
      pluck(:share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3, :privilege_amount).
      map do |inventory|
        inventory.map(&:to_i)
    end
    expect_share_amounts = product_inventories_attributes.map do |inventory|
      [
        (inventory[:price] * 0.08).to_i,
        (inventory[:price] * 0.06).to_i,
        (inventory[:price] * 0.04).to_i,
        (inventory[:price] * 0.02).to_i,
      ]
    end
    assert_equal expect_share_amounts, product_inventories_share_amounts
  end

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
