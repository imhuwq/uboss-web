require 'test_helper'
class ProductTest < ActiveSupport::TestCase
  test 'calculate_share_amount_total' do
    assert_equal(10.0,
                 Product.new(calculate_way: 1, present_price: 100, share_rate_total: 10).calculate_share_amount_total)
    assert_equal(9.33,
                 Product.new(calculate_way: 1, present_price: 100, share_rate_total: 9.333333).calculate_share_amount_total)
  end

  test 'set_default_share_rate_lv_3' do
    p = Product.new(has_share_lv: 3)
    p.set_default_share_rate
    assert_equal(0.2, p.instance_eval { @share_rate_lv_3 })
    assert_equal(0.3, p.instance_eval { @share_rate_lv_2 })
    assert_equal(0.5, p.instance_eval { @share_rate_lv_1 })
    p.set_share_rate
    assert_equal(0.2, p.share_rate_lv_3)
    assert_equal(0.3, p.share_rate_lv_2)
    assert_equal(0.5, p.share_rate_lv_1)
  end
  test 'set_default_share_rate_lv_2' do
    p = Product.new(has_share_lv: 2)
    p.set_default_share_rate
    assert_equal(0.0, p.instance_eval { @share_rate_lv_3 })
    assert_equal(0.4, p.instance_eval { @share_rate_lv_2 })
    assert_equal(0.6, p.instance_eval { @share_rate_lv_1 })
    p.set_share_rate
    assert_equal(0.0, p.share_rate_lv_3)
    assert_equal(0.4, p.share_rate_lv_2)
    assert_equal(0.6, p.share_rate_lv_1)
  end
  test 'set_default_share_rate_lv_1' do
    p = Product.new(has_share_lv: 1)
    p.set_default_share_rate
    assert_equal(0.0, p.instance_eval { @share_rate_lv_3 })
    assert_equal(0.0, p.instance_eval { @share_rate_lv_2 })
    assert_equal(1.0, p.instance_eval { @share_rate_lv_1 })
    p.set_share_rate
    assert_equal(0.0, p.share_rate_lv_3)
    assert_equal(0.0, p.share_rate_lv_2)
    assert_equal(1.0, p.share_rate_lv_1)
  end
  test 'set_share_rate_lv_1' do
    p = Product.new(has_share_lv: 1)
    p.set_share_rate(0.3, 0.2, 0.1)
    assert_equal(0.1, p.share_rate_lv_3)
    assert_equal(0.2, p.share_rate_lv_2)
    assert_equal(0.3, p.share_rate_lv_1)
  end
  test 'calculate_shares' do
    p = Product.new(share_amount_total: 10, has_share_lv: 3, user_id: 1, name: '1', share_rate_lv_2: 0.3, share_rate_lv_3: 0.2)
    p.calculate_shares
    assert_equal(2, p.share_amount_lv_3)
    assert_equal(3, p.share_amount_lv_2)
    assert_equal(5, p.share_amount_lv_1)
  end
  test 'calculate_not_shares' do
    p = Product.new(share_amount_total: 10, has_share_lv: 0, user_id: 1, name: '1', share_rate_lv_2: 0.3, share_rate_lv_3: 0.2)
    p.calculate_shares
    assert_equal(0, p.share_amount_lv_3)
    assert_equal(0, p.share_amount_lv_2)
    assert_equal(0, p.share_amount_lv_1)
  end
  test 'total_sells' do
    buyer = create(:user)
    product = create :product_with_1sharing
    level1_node = create(:sharing_node, product: product)
    level2_node = create(:sharing_node, product: product, parent: level1_node)
    10.times do
      create(:order,
             user: buyer,
             order_items_attributes: [{
               product: product,
               user: buyer,
               amount: 2,
               sharing_node: level2_node
             }],
             state: 'payed'
            )
    end
    assert_equal(20, Product.total_sells(product.id))
  end
end
