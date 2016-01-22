require 'test_helper'

class CityManagerTest < ActiveSupport::TestCase
  describe "Bind User" do
    before do
      create(:city_manager_role)
      @city_manager = create(:city_manager, user: nil)
    end
    it "bind user" do
      user = create(:user)
      assert_not user.has_role?(:city_manager)
      @city_manager.update(user_id: user.id)

      assert user.reload.has_role?(:city_manager)
      assert @city_manager.settled_at.present?
    end

    it "rebind user" do
      user1 = create(:user)
      user2 = create(:user)
      @city_manager.update(user: user1)
      assert user1.reload.has_role?(:city_manager)
      settled_at = @city_manager.settled_at
      @city_manager.update(user: user2)

      assert_not user1.reload.has_role?(:city_manager)
      assert     user2.reload.has_role?(:city_manager)
      assert     settled_at != @city_manager.settled_at
    end
  end
end
