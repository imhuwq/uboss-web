class UserInfo < ActiveRecord::Base

  include Imagable

  belongs_to :user

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
