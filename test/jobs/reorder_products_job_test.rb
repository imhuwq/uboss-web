require 'test_helper'
class ReorderProductsJobTest < ActiveJob::TestCase
  describe 'reorder products' do
    it 'should have expected order' do
      @seller = create(:seller_user)
      @product1 =  create(:product, type: 'OrdinaryProduct', user: @seller, total_sales: 10, published_at: Time.now )
      @product2 =  create(:product, type: 'OrdinaryProduct', user: @seller, total_sales: 20, published_at: Time.now + 200.seconds)
      @product3 =  create(:product, type: 'OrdinaryProduct', user: @seller, total_sales: 30, published_at: Time.now + 100.seconds)
      ReorderProductsJob.perform_now(@seller.id)
      assert_equal 1, @product3.reload.sales_amount_order
      assert_equal 2, @product2.reload.sales_amount_order
      assert_equal 3, @product1.reload.sales_amount_order

      assert_equal 1, @product2.reload.comprehensive_order
      assert_equal 2, @product3.reload.comprehensive_order
      assert_equal 3, @product1.reload.comprehensive_order

    end
  end

end
