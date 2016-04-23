class UserRole < ActiveRecord::Base

  ROLE_NAMES = %w(super_admin seller agent offical_senior offical_financial offical_operating city_manager supplier agency operator)

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

    def roles_can_manage_by_user user
      roles = []
      if user.is_offical_senior?
        roles |= %w(super_admin seller agent offical_operating offical_financial)
      end
      if user.is_offical_operating? || user.is_super_admin?
        roles |= %w(seller agent offical_operating city_manager)
      end
      user_roles = self.where(name: roles)
      user_roles.present? ? user_roles : user.user_roles
    end

    def supplier
      find_by(name: 'supplier')
    end
  end

end
