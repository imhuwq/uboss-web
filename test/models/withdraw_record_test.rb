require 'test_helper'

class WithdrawRecordTest < ActiveSupport::TestCase
  let(:user) { create(:user_with_onek_income) }
  let(:user_info) { user.user_info }

  describe "create new withdraw_record" do
    it 'should frozen user income with amount' do
      assert_equal 1000, user.income
      assert_equal 0, user.frozen_income
      create(:withdraw_record, user: user, amount: 200)
      assert_equal 800, user.user_info.reload.income
      assert_equal 200, user.user_info.reload.frozen_income
    end
  end

  describe "finish withdraw_record" do
    it 'should remove user frozen_income' do
      record = create(:withdraw_record, user: user, amount: 200, state: 'processed')
      assert_nil record.done_at
      assert_equal 200, user_info.reload.frozen_income
      record.finish!
      assert_not_nil record.reload.done_at
      assert_equal 800, user_info.reload.income
      assert_equal 0, user_info.reload.frozen_income
    end
  end

  describe "close withdraw_record" do
    it 'should recover user income with amount' do
      record = create(:withdraw_record, user: user, amount: 200)
      assert_equal 800, user.user_info.reload.income
      assert_equal 200, user.user_info.reload.frozen_income
      record.close!
      assert_equal 1000, user.user_info.reload.income
      assert_equal 0, user.user_info.reload.frozen_income
    end
  end
end
