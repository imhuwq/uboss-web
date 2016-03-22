require 'test_helper'

class ActivityInfoTest < ActiveSupport::TestCase

  test '#should create share_activity_prize for both winner and sharer when win_rate is 100%' do
    seller = create :seller_user
    winner = create :user
    sharer = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    share_activity_info = create(:share_activity_info, promotion_activity: promotion_activity, win_rate: 100)

    draw_prize_result = share_activity_info.draw_share_prize(winner.id, sharer.id)
    assert_equal true, draw_prize_result[:winner_activity_prize_id].present?
    assert_equal true, draw_prize_result[:sharer_activity_prize_id].present?
    assert_equal winner.id, ActivityPrize.find_by_id(draw_prize_result[:winner_activity_prize_id]).prize_winner.id
    assert_equal sharer.id, ActivityPrize.find_by_id(draw_prize_result[:sharer_activity_prize_id]).prize_winner.id
    assert_equal sharer.id, ActivityPrize.find_by_id(draw_prize_result[:winner_activity_prize_id]).sharer_id
    assert_equal share_activity_info.id, ActivityPrize.find_by_id(draw_prize_result[:sharer_activity_prize_id]).activity_info.id
    assert_equal true, ActivityDrawRecord.where(user_id: winner.id, sharer_id: sharer.id, activity_info_id: share_activity_info.id).present?
    assert_equal share_activity_info.win_rate , ActivityPrize.find_by_id(draw_prize_result[:winner_activity_prize_id]).info['win_rate']
  end

  test '#should raise exception when someone draw_share_prize from one sharer twice' do
    seller = create :seller_user
    winner = create :user
    sharer = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    share_activity_info = create(:share_activity_info, promotion_activity: promotion_activity)

    share_activity_info.draw_share_prize(winner.id, sharer.id)
    assert_raises RepeatedActionError do
      share_activity_info.draw_share_prize(winner.id, sharer.id)
    end

  end

  test '#should create live_activity_prize for winner when win_rate is 100%' do
    seller = create :seller_user
    winner = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    live_activity_info = create(:live_activity_info, promotion_activity: promotion_activity, win_rate: 100)

    draw_prize_result = live_activity_info.draw_live_prize(winner.id)
    assert_equal true, draw_prize_result.present?
    assert_equal winner.id, draw_prize_result.prize_winner.id
    assert_equal live_activity_info.id, draw_prize_result.activity_info.id
    assert_equal true, ActivityDrawRecord.where(user_id: winner.id, activity_info_id: live_activity_info.id).present?
  end
  test '#should raise exception when someone draw_live_prize twice' do
    seller = create :seller_user
    winner = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    live_activity_info = create(:live_activity_info, promotion_activity: promotion_activity)

    live_activity_info.draw_live_prize(winner.id)
    assert_raises RepeatedActionError do
      live_activity_info.draw_live_prize(winner.id)
    end

  end
end