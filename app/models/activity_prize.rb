class ActivityPrize < ActiveRecord::Base
  belongs_to :promotion_activity, dependent: :destroy
  belongs_to :activity_info, dependent: :destroy
  belongs_to :prize_winner, class_name: 'User'
  belongs_to :sharer, class_name: 'User'
  validates :activity_info_id, presence: true
  before_create :load_info_oncreate

  def load_info_oncreate
    self.promotion_activity_id = activity_info.promotion_activity_id
    # 方便复查
    info = {}
    info[:draw_count] = (activity_info.activity_type == 'live') ? (activity_info.draw_count ? (activity_info.draw_count + 1) : 1) : 0
    info[:win_rate] = activity_info.win_rate
    info[:win_count] = activity_info.win_count 
    info[:activity_type] = activity_info.activity_type
    # save
  end
end
