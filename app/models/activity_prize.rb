class ActivityPrize < ActiveRecord::Base
  belongs_to :promotion_activity, dependent: :destroy
  belongs_to :activity_info, dependent: :destroy
  belongs_to :prize_winner, class_name: 'User'
  validates :activity_info_id, presence: true
  after_create :load_info_oncreate

  def load_info_oncreate
    self.promotion_activity_id = activity_info.promotion_activity_id
    # 方便复查
    info[:draw_count] = activity_info.draw_count
    info[:win_rate] = activity_info.win_rate
    info[:win_count] = activity_info.win_count + 1
    info[:activity_type] = activity_info.activity_type
    save
  end
end
