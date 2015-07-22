class UserRoleRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_role

  validates :user_id, presence: true
  validates :user_role_id, presence: true
end
