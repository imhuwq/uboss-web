class PromotionActivity < ActiveRecord::Base
  belongs_to :user
  has_many :activity_infos, autosave: true, dependent: :destroy
  has_many :activity_prize, dependent: :destroy
  has_one  :live_activity_info,  -> { where(activity_type: 'live') },  class_name: 'ActivityInfo'
  has_one  :share_activity_info, -> { where(activity_type: 'share') }, class_name: 'ActivityInfo'

  validates :user, :store_type, presence: true

  before_save :seller_can_join_but_one_activity

  accepts_nested_attributes_for :activity_infos

  enum status: { unpublish: 0, published: 1 }

  DATA_STORE_TYPE = {service: '本地服务', ordinary: '电商店铺'}

  def service?
    store_type == 'service'
  end

  def ordinary?
    store_type == 'ordinary'
  end

  def seller_name
      (user.login.present? ? "#{user.login}" : "") +
      (user.email.present? ? "-- #{user.email}" : "")
  end

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

  private
  def seller_can_join_but_one_activity
    if previous_changes.include?(:status) && self.status == "published" && PromotionActivity.where(user_id: user_id, status: 1).count > 0
      self.errors.add(:base, "一个商家只能参与中一个活动，请把该商家参与中的活动下架再上架新的活动。")
      return false
    end
  end

end
