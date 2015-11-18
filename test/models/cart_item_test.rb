require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  describe '#group_by_seller' do
    it 'should group by different seller' do
      cart = create(:cart)
      cart_item1 = create(:cart_item, cart: cart)
      cart_item2 = create(:cart_item, cart: cart)

      group = CartItem.group_by_seller(cart.cart_items)
      assert_equal group[cart_item1.seller], [cart_item1]
      assert_equal group[cart_item2.seller], [cart_item2]
    end
  end

  describe '#valid_items' do
    before do
      cart = create(:cart, cart_items: [create(:cart_item), create(:cart_item)])
      @cart_items = cart.cart_items
      @first_product = @cart_items.first.product
      @first_product_inventory = @cart_items.first.product_inventory
    end

    it 'should return valid cart_items with not published product' do
      valid_items = CartItem.valid_items(@cart_items)
      assert_equal 2, valid_items.count

      @first_product.update_attributes(status: 0)
      valid_items = CartItem.valid_items(@cart_items)
      assert_equal 1, valid_items.count

      @first_product.update_attributes(status: 2)
      valid_items = CartItem.valid_items(@cart_items)
      assert_equal 1, valid_items.count
    end

    it 'should return valid cart_items with not_saling product_inventory' do
      valid_items = CartItem.valid_items(@cart_items)
      assert_equal 2, valid_items.count

      @first_product_inventory.update_attributes(saling: false)
      valid_items = CartItem.valid_items(@cart_items)
      assert_equal 1, valid_items.count
    end

    it 'should return valid cart_items with product_inventory.count = 0' do
      valid_items = CartItem.valid_items(@cart_items)
      assert_equal 2, valid_items.count

      @first_product_inventory.update_attributes(count: 0)
      valid_items = CartItem.valid_items(@cart_items)
      assert_equal 1, valid_items.count
    end
  end

  describe '.product' do
    it 'should return the product_inventory.proudct' do
      product = create(:product)
      cart_item = create(:cart_item, product_inventory: create(:product_inventory, product: product))

      assert_equal product, cart_item.product
    end
  end

  describe '.product_amount' do
    it 'should return the product_inventory.count' do
      product_inventory = create(:product_inventory, count: 10)
      cart_item = create(:cart_item, product_inventory: product_inventory)

      assert_equal product_inventory.count, cart_item.product_amount
    end
  end

  describe '.deal_price' do
    it 'should return the deal_price' do
      cart_item = create(:cart_item, product_inventory: create(:product_inventory, price: 50.0))
      cart_item.expects(:privilege_amount).returns(5)

      assert_equal 45.0, cart_item.deal_price
    end
  end

  describe '.total_price' do
    it 'should return the total_price' do
      cart_item = create(:cart_item, count: 3)
      cart_item.stubs(:deal_price).returns(20)

      assert_equal 60, cart_item.total_price
    end
  end

  describe '.check_count' do
    before do
      @cart_item = create(:cart_item, count: 2, product_inventory: create(:product_inventory, count: 5))
    end

    it 'should return true if count < product_inventory.reload.count' do
      assert @cart_item.check_count
    end

    it 'should return false if count > product_inventory.reload.count' do
      @cart_item.product_inventory.update_attributes(count: 1)
      assert_not @cart_item.check_count
    end

    it 'should return false if count <= 0' do
      @cart_item.update_attributes(count: 0)
      assert_not @cart_item.check_count

      @cart_item.update_attributes(count: -3)
      assert_not @cart_item.check_count
    end
  end
end
