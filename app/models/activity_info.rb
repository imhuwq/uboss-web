class ActivityInfo < ActiveRecord::Base

  include Descriptiontable

  has_one_content name: :description

  belongs_to :promotion_activity

  validates :activity_type, :name, :price, :expiry_days, :win_count, :win_rate, presence: true
  validates :activity_type, inclusion: { in: %w(live share) }
  validates :win_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :promotion_activity_id, uniqueness: { scope: :activity_type }

  def prize_arr
    @win_count = win_count
    @win_rate = win_rate/100
    total = @win_count / @win_rate
    prize_step = (total / @win_count).to_i
    arr = []
    i = 1
    win_count.times do
      arr << i
      i += prize_step
    end
    arr
  end

  def draw_prize(winner_id, sharer_id = nil)
    if !User.find_by_id(winner_id)
      raise ArgumentError.new('winner not found')
    elsif !(sharer_id ? User.find_by_id(sharer_id) : true)
      raise ArgumentError.new('sharer not found')
    elsif promotion_activity.status != 'published'
      raise RuntimeError.new('activity not published or closed')
    else
      ActivityInfo.transaction do
        winner_verify_code_id, sharer_verify_code_id = nil
        if prize_arr.include?(draw_count + 1) # 本次draw_count在中奖数组中
          winner_verify_code_id = VerifyCode.create!.id
          sharer_verify_code_id = sharer_id ? VerifyCode.create!.id : nil
        end
        # 创建抽奖者礼品
        winner_activity_prize = ActivityPrize.create!(activity_info_id: id,
                                                      prize_winner_id: winner_id,
                                                      verify_code_id: winner_verify_code_id)
        update!(draw_count: draw_count ? (draw_count + 1) : 1)

        # 创建分享者礼品
        sharer_activity_info = promotion_activity.activity_infos.where(activity_type: 'share').first
        sharer_activity_prize = nil
        if !sharer_activity_info
          raise RuntimeError.new('share activity_info not found')
        elsif sharer_verify_code_id && sharer_id
          sharer_activity_prize = ActivityPrize.create!(activity_info_id: sharer_activity_info.id,
                                                        prize_winner_id: sharer_id,
                                                        verify_code_id: sharer_verify_code_id)
        end

        return { winner_activity_prize_id: winner_activity_prize.id, sharer_activity_prize_id: sharer_activity_prize.try(:id) }
      end
    end
  end
end
