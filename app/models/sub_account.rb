class SubAccount < ActiveRecord::Base

  include Orderable

  belongs_to :user
  belongs_to :account, class_name: "User"

  validates :user_id, :account_id, presence: true
  validates_uniqueness_of :account_id, scope: :user_id

  enum state: { active: 0, block: 1 }

  before_create :set_default_state

  private

  def set_default_state
    self.state = 'active'
  end

end
