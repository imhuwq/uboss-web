require 'test_helper'

class FavourProductTest < ActiveSupport::TestCase
  let(:user) { create(:user) }
  let(:product) { create(:ordinary_product) }

  it 'should let user favour product' do
    assert_equal 0, user.favour_products.count
    user.favour_product(product)
    assert_equal 1, user.favour_products.count
    assert_equal product.id, user.favour_products.first.product_id
  end

  it 'should let user unfavour product' do
    user.favour_product(product)
    assert_equal 1, user.favour_products.count
    user.unfavour_product(product)
    assert_equal 0, user.favour_products.count
  end

  it 'should not let user favour repeat' do
    user.favour_product(product)
    assert_equal 1, user.favour_products.count
    user.favour_product(product)
    assert_equal 1, user.favour_products.count
  end

end
