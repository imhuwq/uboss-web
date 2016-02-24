require 'test_helper'

class CartTest < ActiveSupport::TestCase
  test 'cart has many cart_items' do
    cart_item = create(:cart_item)
    cart = cart_item.cart
    #cart = create(:cart, cart_items: [cart_item])
    assert cart.cart_items
  end

  describe '.add_product' do
    before do
      @seller = create(:user)
      @cart = create(:cart, user: create(:user))
      @cart_item = create(:cart_item, cart: @cart, seller: @seller)
    end

    it 'should add a new cart_item record if product not exist' do
      count = @cart_item.count
      product_inventory = create(:product_inventory, product: create(:ordinary_product, user: @seller))
      cart_item = @cart.add_product(product_inventory, '', 1)

      assert       cart_item.new_record?
      assert_equal count, @cart_item.count
    end

    it 'should increase cart_item count in cart if product exist' do
      count = @cart_item.count
      product_inventory = @cart_item.product_inventory
      cart_item = @cart.add_product(product_inventory, '', 1)

      assert_not   cart_item.new_record?
      assert_equal count + 1, cart_item.count
    end
  end

  describe '.remove_product_from_cart' do
    it 'should remove cart_item with product_inventory_id' do
      cart = create(:cart, cart_items: [create(:cart_item), create(:cart_item)])
      product_inventory = cart.cart_items.first.product_inventory
      assert_equal 2, cart.cart_items.count

      cart.remove_product_from_cart(product_inventory.id)
      assert_equal 1, cart.cart_items.count
    end
  end

  describe '.remove_all_products_in_cart' do
    it 'should remove all cart_item from cart' do
      cart = create(:cart, cart_items: [create(:cart_item), create(:cart_item)])
      assert_equal 2, cart.cart_items.count

      cart.remove_all_products_in_cart
      assert_equal 0, cart.cart_items.count
    end
  end

  describe '.remove_cart_items' do
    it 'should remove cart_items with cart_item_ids' do
      cart = create(:cart, cart_items: [create(:cart_item), create(:cart_item)])
      cart_item_ids = cart.cart_items.pluck(:id)
      create(:cart_item, cart: cart)
      assert_equal 3, cart.cart_items.count

      cart.remove_cart_items(cart_item_ids)
      assert_equal 1, cart.cart_items.count
    end
  end

  describe '.change_cart_item_count' do
    it 'should change cart_item count' do
      cart_item = create(:cart_item, count: 5)
      cart = cart_item.cart
      product_inventory = cart_item.product_inventory

      cart.change_cart_item_count(product_inventory.id, 10, cart.id)
      assert_equal 10, cart_item.reload.count
    end
  end

  describe '.sum_items_count' do
    it 'should sum all cart_items count' do
      cart = create(:cart, cart_items: [
        create(:cart_item, count: 3),
        create(:cart_item, count: 2)
      ])

      assert_equal 5, cart.sum_items_count
    end
  end

  describe '.total_price' do
    it 'should calculate total_price of cart' do
      product = create(:ordinary_product)
      cart = create(:cart, cart_items: [
        create(:cart_item, count: 3, product_inventory: create(:product_inventory, product: product, price: 20)),
        create(:cart_item, count: 1, product_inventory: create(:product_inventory, product: product, price: 200))
      ])

      total_price = cart.total_price
      assert_equal 3*20+200, total_price
    end
  end
end
