require 'test_helper'

class ActivityInfoTest < ActiveSupport::TestCase

  test '#should create share_activity_prize for both winner and sharer when win_rate is 100%' do
    seller = create :seller_user
    winner = create :user
    sharer = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    share_activity_info = create(:share_activity_info, promotion_activity: promotion_activity, win_rate: 100)

    draw_prize_result = share_activity_info.draw_share_prize(winner.id, sharer.id)
    assert_equal true, draw_prize_result[:winner_activity_prize].try(:present?)
    assert_equal true, draw_prize_result[:sharer_activity_prize].try(:present?)
    assert_equal winner.id, ActivityPrize.find_by_id(draw_prize_result[:winner_activity_prize]).prize_winner.id
    assert_equal sharer.id, ActivityPrize.find_by_id(draw_prize_result[:sharer_activity_prize]).prize_winner.id
    assert_equal sharer.id, ActivityPrize.find_by_id(draw_prize_result[:winner_activity_prize]).sharer_id
    assert_equal share_activity_info.id, ActivityPrize.find_by_id(draw_prize_result[:sharer_activity_prize]).activity_info.id
    assert_equal true, ActivityDrawRecord.where(user_id: winner.id, sharer_id: sharer.id, activity_info_id: share_activity_info.id).present?
    assert_equal share_activity_info.win_rate , ActivityPrize.find_by_id(draw_prize_result[:winner_activity_prize]).info['win_rate']
    verify_code =  VerifyCode.find_by(activity_prize_id: draw_prize_result[:winner_activity_prize])
    assert_equal true, verify_code.present?
    assert_equal true, verify_code.verify_activity_code(seller)[:success]
    assert_equal 100, verify_code.activity_prize.activity_info.win_rate
    assert_equal share_activity_info.win_rate , ActivityPrize.find_by_id(draw_prize_result[:winner_activity_prize]).info['win_rate']
  end

  test '#should not create share_activity_prize twice when win_rate is 1%' do
    seller = create :seller_user
    winner = create :user
    winner2 = create :user
    sharer = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    share_activity_info = create(:share_activity_info, promotion_activity: promotion_activity, win_rate: 1)

    draw_prize_result = share_activity_info.draw_share_prize(winner.id, sharer.id)
    draw_prize_result2 = share_activity_info.draw_share_prize(winner2.id, sharer.id)
    assert_equal nil, draw_prize_result[:winner_activity_prize_id].try(:present?) && draw_prize_result2[:winner_activity_prize_id].try(:present?)
    assert_equal true, ActivityDrawRecord.where(user_id: winner.id, sharer_id: sharer.id, activity_info_id: share_activity_info.id).present?
  end

  test '#should raise exception when someone draw_share_prize from one sharer twice' do
    seller = create :seller_user
    winner = create :user
    sharer = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    share_activity_info = create(:share_activity_info, promotion_activity: promotion_activity)

    share_activity_info.draw_share_prize(winner.id, sharer.id)
    result =  share_activity_info.draw_share_prize(winner.id, sharer.id)
    assert_equal 'you have already drawed prize', result[:message]
    assert_equal 500, result[:status]

  end

  test '#should create live_activity_prize for winner when win_rate is 100%' do
    seller = create :seller_user
    winner = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    live_activity_info = create(:live_activity_info, promotion_activity: promotion_activity, win_rate: 100)

    draw_prize_result = live_activity_info.draw_live_prize(winner.id)
    assert_equal true, draw_prize_result[:winner_activity_prize].present?
    assert_equal winner.id, draw_prize_result[:winner_activity_prize].prize_winner.id
    assert_equal live_activity_info.id, draw_prize_result[:winner_activity_prize].activity_info.id
    assert_equal true, ActivityDrawRecord.where(user_id: winner.id, activity_info_id: live_activity_info.id).present?
  end
  test '#should raise exception when someone draw_live_prize twice' do
    seller = create :seller_user
    winner = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    live_activity_info = create(:live_activity_info, promotion_activity: promotion_activity)

    live_activity_info.draw_live_prize(winner.id)
    result = live_activity_info.draw_live_prize(winner.id)
    assert_equal 500, result[:status]
    assert_equal 'you have already drawed prize', result[:message]

  end

  test '#should recaculate surplus when update win_rate' do
    seller = create :seller_user
    winner = create :user
    sharer = create :user
    winner2 = create :user
    winner3 = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    share_activity_info = create(:share_activity_info, promotion_activity: promotion_activity, win_rate: 100)
    assert_equal share_activity_info.surplus, share_activity_info.win_count

    share_activity_info.draw_share_prize(winner.id, sharer.id)
    share_activity_info.draw_share_prize(winner2.id, sharer.id)
    share_activity_info.draw_share_prize(winner3.id, sharer.id)
    share_activity_info.update(win_rate: 90)
    assert_equal false, share_activity_info.surplus == share_activity_info.win_count
    assert_equal share_activity_info.surplus + share_activity_info.activity_prizes.count, share_activity_info.win_count
  end

  test '#should raise exception when prize < 0' do
    seller = create :seller_user
    winner = create :user
    winner2 = create :user
    sharer = create :user
    promotion_activity = create(:active_promotion_activity, user: seller)
    live_activity_info = create(:live_activity_info, promotion_activity: promotion_activity, win_count: 1, win_rate: 100)
    share_activity_info = create(:share_activity_info, promotion_activity: promotion_activity, win_count: 1, win_rate: 100)

    result =  share_activity_info.draw_share_prize(winner2.id, sharer.id)
    assert_equal 'No prize surplus', result[:message]
    live_activity_info.draw_live_prize(winner.id)
    result2 = live_activity_info.draw_live_prize(winner2.id)
    assert_equal 'No prize surplus', result2[:message]

  end
end
