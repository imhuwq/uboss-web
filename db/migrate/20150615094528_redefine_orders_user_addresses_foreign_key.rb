class RedefineOrdersUserAddressesForeignKey < ActiveRecord::Migration
  def change
    remove_foreign_key "orders", "user_addresses"
    add_foreign_key "orders", "user_addresses", on_delete: :nullify
  end
end
