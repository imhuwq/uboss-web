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

  describe '运费计算' do
    it '单个物品包邮' do
    end

    it '单个物品统一运费' do
    end

    it '含有包邮和统一运费' do
    end

    it '含有包邮和模板' do
    end

    it '含有统一运费和模板' do
    end

    it '含有包邮, 统一, 模板' do
    end
  end

  describe '单个物品模板' do
    it '件数大于首费情况' do
    end

    it '件数小于首费情况' do
    end
  end
end
