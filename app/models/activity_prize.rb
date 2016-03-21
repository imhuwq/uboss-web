class ActivityPrize < ActiveRecord::Base
  belongs_to :promotion_activity
  belongs_to :activity_info
  belongs_to :prize_winner, class_name: 'User'
  belongs_to :sharer, class_name: 'User'
  validates :activity_info_id, presence: true
  before_create :load_info_oncreate

  def load_info_oncreate
    self.promotion_activity_id = activity_info.promotion_activity_id
    # 方便复查
    hash = {}
    hash['draw_count'] = activity_info.draw_count ? activity_info.draw_count : 1
    hash['win_rate'] = activity_info.win_rate
    hash['win_count'] = activity_info.win_count
    hash['activity_type'] = activity_info.activity_type
    self.info = hash
  end

  def expire_at
    created_at + activity_info.expiry_days.days
  end
end
