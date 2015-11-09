class AddUniqIndexForUniqColumns < ActiveRecord::Migration
  def change
    add_index :agent_invite_seller_histroys, [:mobile, :agent_id], unique: true
    add_index :agent_invite_seller_histroys, [:invite_code, :agent_id], unique: true

    add_index :cart_items, [:product_inventory_id, :cart_id], unique: true

    add_index :enterprise_authentications, :user_id, unique: true

    add_index :expresses, :name, unique: true

    add_index :favour_products, [:product_id, :user_id], unique: true

    add_index :personal_authentications, :user_id, unique: true
    add_index :personal_authentications, :identity_card_code, unique: true

    add_index :privilege_cards, [:user_id, :seller_id], unique: true

    add_index :users, :email, unique: true
    add_index :users, :agent_code, unique: true

    add_index :user_roles, :name, unique: true

    ActiveRecord::Base.connection.execute <<-SQL.squish!
DELETE user_role_relations
FROM user_role_relations
LEFT OUTER JOIN (
   SELECT MIN(id) as id
   FROM user_role_relations
   GROUP BY user_id, user_role_id
) as KeepRows ON user_role_relations.id = KeepRows.id
WHERE KeepRows.id IS NULL
    SQL
    add_index :user_role_relations, [:user_id, :user_role_id], unique: true

    add_index :descriptions, [:resource_type, :resource_id], unique: true

    add_index :order_charges, :number, unique: true
  end
end
