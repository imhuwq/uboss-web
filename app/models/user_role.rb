class UserRole < ActiveRecord::Base

  ROLE_NAMES = %w(super_admin seller agent)

  belongs_to :user
  has_many :user_role_relations, dependent: :destroy
  has_many :users, through: :user_role_relations

  validates :name, uniqueness: true, inclusion: { in: ROLE_NAMES }

  User.class_eval do
    ROLE_NAMES.each do |key|
      define_method "#{key}?" do
        role_name == key
      end
    end
  end

end
