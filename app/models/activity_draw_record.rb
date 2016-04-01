class ActivityDrawRecord < ActiveRecord::Base
  belongs_to :promotion_activity
  belongs_to :activity_info
  belongs_to :user
  belongs_to :sharer, class_name: 'User'

  validates :activity_info_id, presence: true
  validates :user_id, uniqueness: { scope: [:sharer_id, :activity_info_id] }

  before_create :load_info_oncreate

  def load_info_oncreate
    self.promotion_activity_id = activity_info.promotion_activity_id
    self.draw_count = activity_info.draw_count
  end
end
