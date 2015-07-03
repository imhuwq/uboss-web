class UserRole < ActiveRecord::Base

  ROLE_NAMES = %w(super_admin seller)

  belongs_to :user

  validates :name, uniqueness: true, inclusion: { in: ROLE_NAMES }

  User.class_eval do
    ROLE_NAMES.each do |key|
      define_method "#{key}?" do
        role_name == key
      end
    end
  end

end
