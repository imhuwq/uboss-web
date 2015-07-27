class UserRole < ActiveRecord::Base

  ROLE_NAMES = %w(super_admin seller agent)

  belongs_to :user
  has_many :user_role_relations, dependent: :destroy
  has_many :users, through: :user_role_relations

  validates :name, uniqueness: true, inclusion: { in: ROLE_NAMES }

  class << self
    def agent
      find_by(name: 'agent')
    end

    def super_admin
      find_by(name: 'super_admin')
    end

    def seller
      find_by(name: 'seller')
    end
  end

end
