require 'test_helper'

class SharingNodeTest < ActiveSupport::TestCase

  describe '#find_or_create_by_resource_and_parent' do
    before do
      @user = create(:user)
      @seller = create(:user)
      @product = create(:ordinary_product)
    end

    it 'should find resource sharing node & touch it' do
      node = create(:sharing_node, product: @product, user: @user)
      seller_node = create(:sharing_node, seller: @seller, user: @user)
      query_node = SharingNode.find_or_create_by_resource_and_parent(@user, @product)
      query_seller_node = SharingNode.find_or_create_by_resource_and_parent(@user, @seller)
      assert_equal query_node.id, node.id
      assert_equal query_seller_node.id, seller_node.id
    end

    it 'should return parent if parant_user is use self' do
      parent_node = create(:sharing_node, product: @product, user: @user)
      query_node = SharingNode.find_or_create_by_resource_and_parent(@user, @product, parent_node)
      assert_equal query_node, parent_node
    end

    it 'should touch node if parent present & not self' do
      parent_user = create(:user)
      parent_node = create(:sharing_node, product: @product, user: parent_user)
      node = create(:sharing_node, product: @product, user: @user, parent: parent_node)
      travel 1.day
      query_node = SharingNode.find_or_create_by_resource_and_parent(@user, @product, parent_node)
      assert_equal query_node.id, node.id
      assert query_node.updated_at > node.updated_at
    end

    it 'should generate a new sharing node if none exists' do
      assert_equal 0, SharingNode.count
      query_node = SharingNode.find_or_create_by_resource_and_parent(@user, @product)
      assert_equal 1, SharingNode.count
      assert_equal @product.id, query_node.product_id
    end
  end

  describe '#lastest_product_sharing_node' do
    it 'should return self if node is product' do
      product_node = create(:sharing_node_with_product)
      query_node = product_node.lastest_product_sharing_node(product_node.product)
      assert_equal query_node, product_node
    end

    it 'should find a product node' do
      seller_node = create(:sharing_node_with_seller)
      product = create(:ordinary_product)
      query_node = seller_node.lastest_product_sharing_node(product)
      assert query_node.persisted?
      assert_equal product.id, query_node.product_id
    end
  end

  describe '#lastest_seller_sharing_node' do
    it 'should return self if node is seller' do
      seller_node = create(:sharing_node_with_seller)
      query_node = seller_node.lastest_seller_sharing_node
      assert_equal query_node, seller_node
    end

    it 'should find a seller node' do
      product_node = create(:sharing_node_with_product)
      query_node = product_node.lastest_seller_sharing_node
      assert query_node.persisted?
      assert_equal query_node.seller_id, product_node.product.user_id
    end
  end

end
