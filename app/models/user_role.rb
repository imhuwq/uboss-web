class UserRole < ActiveRecord::Base

  ROLE_NAMES = %w(super_admin seller agent offical_senior offical_financial offical_operating)

  belongs_to :user
  has_many :user_role_relations, dependent: :destroy
  has_many :users, through: :user_role_relations

  validates :name, uniqueness: true, inclusion: { in: ROLE_NAMES }

  class << self
    ROLE_NAMES.each do |role|
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{role}
          @#{role} ||= find_by(name: '#{role}')
        end
      RUBY
    end
  end

end
