require 'test_helper'

class PrivilegeCardTest < ActiveSupport::TestCase

  describe 'with 50 user privilege_rate' do
    before do
      # @sharing_user = create(:user, privilege_rate: 50)
      # @product = create(:product_with_3sharing)
      # @product.update_columns(
      #   share_amount_lv_1: 10,
      #   share_amount_lv_2: 5,
      #   share_amount_lv_3: 2,
      #   privilege_amount: 5,
      #   present_price: 100
      # )
      # @privilege_card = create(:privilege_card, user: @sharing_user, seller: @product.user)

      @sharing_user = create(:user, privilege_rate: 50)
      @product = create(:product_with_3sharing)
      @product_inventory = ProductInventory.new(price: 100)
      @product_inventory.product = @product
      @product_inventory.save( :validate => false)
      @product_inventory.update_columns(
        share_amount_lv_1: 10,
        share_amount_lv_2: 5,
        share_amount_lv_3: 2,
        privilege_amount: 5,
        price: 100,
        user_id: @product.user_id
      )
      @privilege_card = create(:privilege_card, user: @sharing_user, seller: @product_inventory.user)
    end

    it 'should cal right returning_amount' do
      assert_equal 5, @privilege_card.returning_amount(@product_inventory)
    end

    it 'should cal right privilege_card amount' do
      assert_equal 5, @privilege_card.amount(@product_inventory)
    end

    it 'should cal right privilege_amount' do
      assert_equal 10, @privilege_card.privilege_amount(@product_inventory)
    end

    it 'discount right' do
      assert_equal 9, @privilege_card.discount(@product_inventory)
    end
  end

end
