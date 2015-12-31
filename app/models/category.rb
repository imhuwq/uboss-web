class Category < ActiveRecord::Base

	include Imagable

  belongs_to :user
  has_many :advertisements
  has_and_belongs_to_many :products, -> { uniq }

  has_one_image autosave: true

  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img

  validates_presence_of :user_id, :name
  validates :name, uniqueness: { scope: :user_id, message: :exists }

  def asset_img
    super || build_asset_img
  end

  def self.find_or_new_by(*args)
    category = Category.find_by(*args)
    unless category
      category = Category.new(*args)
    end
    category
  end

end
