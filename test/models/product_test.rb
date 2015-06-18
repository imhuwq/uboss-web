require 'test_helper'
# require 'test/unit'
class ProductTest < ActiveSupport::TestCase
  def test_calculate_share_amount_total
  	assert_equal(10.0,Product.new(calculate_way:1,present_price:100,share_rate_total:10).calculate_share_amount_total)
  end
end