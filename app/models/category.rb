class Category < ActiveRecord::Base

	include Imagable

  belongs_to :user
  belongs_to :store, polymorphic: true
  has_many :advertisements
  has_and_belongs_to_many :products, -> { uniq }

  acts_as_list scope: :user

  has_one_image autosave: true

  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img
  default_scope -> { order(position: :asc) }

  scope :dishes_categories, -> {where(store_type: 'ServiceStore')}
  scope :electricity_categories, -> {where(store_type: 'OrdinaryStore')}

  validates_presence_of :user_id, :name
  validates :name, uniqueness: { :scope => [:user_id, :store_id], message: :exists }
  validate :validate_position
  before_destroy :move_product_to_default_category
  after_create :move_default_category_to_bottom

  def asset_img
    super || build_asset_img
  end

  def is_default?
    self.name == '其他'
  end

  def self.find_or_new_by(*args)
    category = Category.find_by(*args)
    unless category
      category = Category.new(*args)
    end
    category
  end

  private
  def validate_position
    if position.present?
      max = user.categories.maximum(:position).to_i + 1
      self.errors.add(:position, "必须小于或等于#{max}") if position.to_i > max
    end
  end

  def move_default_category_to_bottom
    Category.find_by(name: '其他', user_id: user_id).try(:move_to_bottom)
  end

  def move_product_to_default_category
    if self.store_type == 'ServiceStore'
      default_category = self.user.categories.find_or_create_by(name: '其他',store_id: self.store_id, store_type: self.store_type)
      self.products.find_each do |product|
        product.categories << default_category
      end
    end
  end
end
