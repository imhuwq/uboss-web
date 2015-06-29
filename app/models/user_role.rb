class UserRole < ActiveRecord::Base

  ROLE_NAMES = %w(super_admin seller)

  validates :name, uniqueness: true, inclusion: { in: ROLE_NAMES }

end
