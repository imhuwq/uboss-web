require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  describe 'order closed' do
    it 'should recover sku strock' do
      buy_amount = 10
      product = create(:product, count: 100)
      buyer = create(:user)

      order = create(:order,
                      user: buyer,
                      order_items_attributes: [{
                        product: product,
                        user: buyer,
                        amount: buy_amount
                      }]
                     )

      assert_equal 90, product.reload.count

      order.close!

      assert_equal 100, product.reload.count
    end
  end
end
