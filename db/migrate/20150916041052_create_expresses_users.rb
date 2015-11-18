class CreateExpressesUsers < ActiveRecord::Migration
  def change
    create_table :expresses_users, id: false do |t|
      t.integer :express_id
      t.integer :user_id
    end
  end
end
