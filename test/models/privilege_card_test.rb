require 'test_helper'

class PrivilegeCardTest < ActiveSupport::TestCase

  describe 'with 50 user privilege_rate' do
    before do
      @sharing_user = create(:user, privilege_rate: 50)
      @product = create(:product_with_3sharing)
      @product.update_columns(
        share_amount_lv_1: 10,
        share_amount_lv_2: 5,
        share_amount_lv_3: 2,
        privilege_amount: 5,
        present_price: 100
      )
      @privilege_card = create(:privilege_card, user: @sharing_user, seller: @product.user)
    end

    it 'should cal right returning_amount' do
      assert_equal 5, @privilege_card.returning_amount(@product)
    end

    it 'should cal right privilege_card amount' do
      assert_equal 5, @privilege_card.amount(@product)
    end

    it 'should cal right privilege_amount' do
      assert_equal 10, @privilege_card.privilege_amount(@product)
    end

    it 'discount right' do
      assert_equal 9, @privilege_card.discount(@product)
    end
  end

end
