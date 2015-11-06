FactoryGirl.define do
  factory :user_role_relation do
    user

    factory :seller_role_relation do
      user_role { UserRole.find_by(name: 'seller') || create(:seller_role) }
    end

    factory :agent_role_relation do
      user_role { UserRole.find_by(name: 'agent') || create(:agent_role) }
    end

    factory :admin_role_relation do
      user_role { UserRole.find_by(name: 'super_admin') || create(:admin_role) }
    end
  end
end
