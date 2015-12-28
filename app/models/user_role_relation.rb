class UserRoleRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_role

  #validates :user_id, presence: true
  validates :user_role_id, presence: true
  validates_uniqueness_of :user_id, scope: :user_role_id, message: :already_has_role
end
