class UserInfo < ActiveRecord::Base

  include Imagable

  belongs_to :user

  has_one_image name: :store_logo, autosave: true
  # delegate :store_logo=, :avatar, to: :store_logo
  # delegate  :avatar, :store_logo=, to: :store_logo
  def  store_logo_url(option='thumb')
    store_logo.try(:image_url, option)
  end

  def store_logo=(file)
    store_logo.avatar=(file)
  end

  def store_logo
    super || build_store_logo
  end

  def store_title
    if store_name.blank?
      nil
    else
      short_desc = store_short_description.blank? ? nil : store_short_description
      [store_name, short_desc].compact.join(" | ")
    end
  end

  def store_identify
    store_name || user.nickname || user.mobile || 'UBOSS商家'
  end

  mount_uploader :store_banner_one, ImageUploader
  mount_uploader :store_banner_two, ImageUploader
  mount_uploader :store_banner_thr, ImageUploader
  mount_uploader :store_cover,      ImageUploader

  compatible_with_form_api_images :store_banner_one, :store_banner_two, :store_banner_thr, :store_cover

  scope :ordinary_store, -> { where(type: 'OrdinaryStore') }
  scope :service_store, -> { where(type: 'ServiceStore') }

  def good_reputation_rate
    return @sharer_good_reputation_rate if @sharer_good_reputation_rate
    good = best_evaluation.to_i + better_evaluation.to_i + good_evaluation.to_i
    @sharer_good_reputation_rate = if total_reputations > 0
                                     good * 100 / total_reputations
                                   else
                                     100
                                   end
  end

  def total_reputations
    @total_reputations ||= (good_evaluation.to_i + bad_evaluation.to_i + better_evaluation.to_i + best_evaluation.to_i + worst_evaluation.to_i)
  end
end
