require 'test_helper'

class EvaluationTest < ActiveSupport::TestCase
  describe 'Create Evaluation' do
    it 'should have match attrs' do
      buyer = create(:user)
      product = create :product_with_1sharing
      product_inventory = create(:product_inventory, product: product)
      level1_node = create(:sharing_node, product: product)
      level2_node = create(:sharing_node, product: product, parent: level1_node)
      order = create(:order,
                     user: buyer,
                     order_items_attributes: [{
                       product: product,
                       product_inventory: product_inventory,
                       user: buyer,
                       amount: 2,
                       sharing_node: level2_node
                     }],
                     state: 'payed'
                    )
      evaluation = create(:evaluation, order_item: order.order_items.first, status: 1)
      assert_equal evaluation.buyer_id, buyer.id
      assert_equal evaluation.sharer_id, order.order_items.first.sharing_node.user_id
      assert_equal evaluation.product_id, order.order_items.first.product_id
      assert_equal '100.00%', Evaluation.product_good_reputation_rate(product.id)
      assert_equal '100.00%', Evaluation.sharer_good_reputation_rate(level2_node.user)
      order2 = create(:order,
                      user: buyer,
                      order_items_attributes: [{
                        product: product,
                        product_inventory: product_inventory,
                        user: buyer,
                        amount: 2,
                        sharing_node: level2_node
                      }],
                      state: 'payed'
                     )
      create(:evaluation, order_item: order2.order_items.first, status: 2)
      assert_equal '50.00%', Evaluation.product_good_reputation_rate(product)
      assert_equal '50.00%', Evaluation.sharer_good_reputation_rate(level2_node.user)
    end
  end
end
