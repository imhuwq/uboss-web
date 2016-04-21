class ActivityInfo < ActiveRecord::Base
  include Descriptiontable

  has_one_content name: :description

  has_many   :activity_prizes, dependent: :destroy
  has_many   :live_prizes,  -> { where(activity_type: 'live') },  class_name: 'ActivityPrize'
  has_many   :share_prizes, -> { where(activity_type: 'share') }, class_name: 'ActivityPrize'
  has_many   :activity_draw_records, dependent: :destroy
  belongs_to :promotion_activity

  validates :activity_type, :name, :expiry_days, :win_count, :win_rate, presence: true
  validates :activity_type, inclusion: { in: %w(live share) }
  validates :win_rate, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :win_count, :expiry_days, numericality: { greater_than: 0 }
  validates :promotion_activity_id, uniqueness: { scope: :activity_type }

  before_save :examine_win_rate

  def verified_verify_codes
    prize_ids = activity_type == 'live' ? live_prizes.pluck(:id) : share_prizes.pluck(:id)
    VerifyCode.where(activity_prize_id: prize_ids, verified: true)
  end

  def prize_arr
    prize_count = activity_type == 'live' ? surplus : surplus / 2
    prize_interval = 100 / win_rate
    prize_step = prize_interval.to_i
    f = prize_interval - prize_step
    arr = []
    i = 0
    e = 0

    prize_count.times do
      i += prize_step
      if e >= 1
        e -= 1
        i += 1
      end
      arr << i
      e += f
    end

    arr
  end

  def draw_share_prize(winner_id, sharer_id)
    if !User.find_by_id(winner_id)
      raise ArgumentError.new('winner not found')
    elsif promotion_activity.status != 'published'
      return {status: 500, message: :not_published }
    elsif activity_type != 'share'
      raise RuntimeError.new('wrong method used')
    elsif !User.find_by_id(sharer_id)
      return {status: 500, message: :not_found }
    elsif ActivityDrawRecord.find_by(user_id: winner_id, sharer_id: sharer_id, activity_info_id: id).present?
      return {status: 500, message: :already_drawed }
    elsif !prize_arr.present? || prize_arr.last <= draw_count
      return {status: 500, message: :no_prize }
    else
      ActivityInfo.transaction do
        self.lock!
        update!(draw_count: draw_count ? (draw_count + 1) : 1)
        winner_activity_prize, sharer_activity_prize = nil
        if prize_arr.include?(draw_count) # 本次draw_count在中奖数组中
          # 创建抽奖者礼品
          winner_activity_prize = ActivityPrize.create!(activity_info_id: id,
                                                        sharer_id: sharer_id,
                                                        prize_winner_id: winner_id)

          # 创建分享者礼品
          sharer_activity_prize = ActivityPrize.create!(activity_info_id: id,
                                                        prize_winner_id: sharer_id,
                                                        relate_winner_id: winner_id) # 检查这份奖品是因为谁中奖二连带获得的
          VerifyCode.create!(activity_prize_id: winner_activity_prize.id, user_id: winner_activity_prize.prize_winner_id)
          VerifyCode.create!(activity_prize_id: sharer_activity_prize.id, user_id: sharer_activity_prize.prize_winner_id)
        end
        ActivityDrawRecord.create!(activity_info_id: id, user_id: winner_id, sharer_id: sharer_id)

        if winner_activity_prize.present?
          return {status: 200, winner_activity_prize: winner_activity_prize.id, sharer_activity_prize: sharer_activity_prize }
        else
          return {status: 200}
        end
      end
    end
  end

  def draw_live_prize(winner_id)
    if !User.find_by_id(winner_id)
      raise ArgumentError.new('winner not found')
    elsif promotion_activity.status != 'published'
      return {status: 500, message: :not_published }
    elsif activity_type != 'live'
      raise RuntimeError.new('wrong method used')
    elsif ActivityDrawRecord.find_by(user_id: winner_id, activity_info_id: id).present?
      return {status: 500, message: :already_drawed }
    elsif !prize_arr.present? || prize_arr.last <= draw_count
      return {status: 500, message: :no_prize }
    else
      ActivityInfo.transaction do
        self.lock!
        winner_activity_prize = nil
        if prize_arr.include?(draw_count + 1) # 本次draw_count在中奖数组中
          winner_activity_prize = ActivityPrize.create!(activity_info_id: id,
                                                        prize_winner_id: winner_id)
          VerifyCode.create!(activity_prize_id: winner_activity_prize.id, user_id: winner_activity_prize.prize_winner_id)
        end
        # 创建抽奖者礼品
        update!(draw_count: draw_count ? (draw_count + 1) : 1)
        ActivityDrawRecord.create!(activity_info_id: id, user_id: winner_id)

        return {status: 200, winner_activity_prize: winner_activity_prize}
      end
    end
  end

  def examine_win_rate
    if self.new_record? || attribute_changed?(:win_rate)
      self.surplus = self.win_count - self.activity_prizes.count
      self.draw_count = 0
    end

  end

end

