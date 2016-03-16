class PromotionActivity < ActiveRecord::Base
  belongs_to :user
  has_many :activity_infos, autosave: true, dependent: :destroy
  has_one  :live_activity_info,  -> { where(activity_type: 'live') },  class_name: 'ActivityInfo'
  has_one  :share_activity_info, -> { where(activity_type: 'share') }, class_name: 'ActivityInfo'

  accepts_nested_attributes_for :activity_infos

  enum status: { unpublish: 0, published: 1, closed: 2 }

  def live_activity_info
    super || build_live_activity_info
  end

  def share_activity_info
    super || build_share_activity_info
  end

  def share_path_draw_prize(winner_id,sharer_id)
    self.activity_infos.where(activity_type: 'live').draw_prize(winner_id)
    self.activity_infos.where(activity_type: 'share').draw_prize(winner_id)
  end
end
