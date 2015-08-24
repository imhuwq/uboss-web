class UserRole < ActiveRecord::Base

  ROLE_NAMES = %w(super_admin seller agent).freeze

  has_many :user_role_relations, dependent: :destroy
  has_many :users, through: :user_role_relations

  validates :name, uniqueness: true, inclusion: { in: ROLE_NAMES }

  class << self
    ROLE_NAMES.each do |role|
      define_method role do
        find_by(name: role)
      end
    end
  end

end
