require 'test_helper'

class SupplierProductTest < ActiveSupport::TestCase
  before do
    @user = create(:user)
    @product = create(:supplier_product)
    @child_product = @product.amoeba_dup
    @child_product.user_id = @user.id
    @child_product.save!
  end

  test "Shelf products" do
    @info = @product.supplier_product_info
    @product.supplied
    assert_equal @info.supply_status, "supplied"
    assert_equal @product.children.all? {|c| c.published? }, true
  end

  test "Of Stock" do
    @info = @product.supplier_product_info
    @product.stored
    assert_equal @info.supply_status, "stored"
    assert_equal @product.children.all? {|c| c.unpublish? }, true
  end
end
