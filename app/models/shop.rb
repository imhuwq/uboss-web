class Shop < ActiveRecord::Base
  include Orderable
  include Userdelegator
  include Imagable
  belongs_to :user
  belongs_to :operator
  belongs_to :clerk
  has_one_image autosave: true
  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img
  delegate :mobile, :name, to: :clerk, allow_nil: true, prefix: true

  attr_accessor :login

  validates :operator_id, :province, :city, :district, :mobile, :name, :address, presence: true
  validates :login, presence: true, on: :create, if: -> { user_id.blank? }

  before_create :binding_user, if: -> { user.blank? }
  after_create :active_user
  after_create :add_seller_role!
  after_save :save_clerk!

  def binding_user
    self.user ||= User.find_or_create_guest_with_session(login, {})
  end

  def active_user
    Ubonus::Invite.delay.active_by_user_id(user_id)
  end
  
  def clerk=(c)
    if c.is_a?(Hash)
      super Clerk.find_or_initialize_by({mobile: c[:mobile]}).tap {|clerk| clerk.name = c[:name] }
    else
      super
    end
  end

  def add_seller_role!
    user.add_role :seller
  end

  def save_clerk!
    clerk.changed? && clerk.save!
  end
end
