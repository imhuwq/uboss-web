class Shop < ActiveRecord::Base
  include Orderable
  include Userdelegator
  include Imagable
  belongs_to :user
  belongs_to :operator
  belongs_to :clerk
  has_many :online_orders, class_name: 'Order', foreign_key: :seller_id, primary_key: :user_id
  has_many :offline_orders, class_name: 'BillOrder', foreign_key: :seller_id, primary_key: :user_id
  has_one_image autosave: true
  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img
  delegate :mobile, :name, to: :clerk, allow_nil: true, prefix: true
  scope :online_turnovers, -> (segment=:today){ joins(:online_orders).merge(Order.have_paid.send(segment)).sum("orders.paid_amount") }
  scope :offline_turnovers, -> (segment=:today){ joins(:offline_orders).merge(BillOrder.payed.send(segment)).sum("bill_orders.paid_amount") }

  attr_accessor :login

  validates :operator_id, :province, :city, :district, :mobile, :name, :address, presence: true
  validates :login, presence: true, on: :create, if: -> { user_id.blank? }

  before_create :binding_user, if: -> { user.blank? }
  after_create :active_user
  after_save :save_clerk!

  def binding_user
    self.user = User.find_or_create_guest_with_session(login, {}) if login
  end

  def active_user
    Ubonus::Invite.delay.active_by_user_id(user_id)
  end

  def online_turnovers(segment=:all)
    self.class.where(id: id).online_turnovers(segment)
  end

  def offline_turnovers(segment=:all)
    self.class.where(id: id).offline_turnovers(segment)
  end

  def clerk=(c)
    if c.is_a?(Hash)
      super Clerk.find_or_initialize_by({mobile: c[:mobile]}).tap {|clerk| clerk.name = c[:name] }
    else
      super
    end
  end

  def save_clerk!
    clerk.changed? && clerk.save!
  end
end
