class CreateOperators < ActiveRecord::Migration
  def change
    create_table :operators do |t|
      t.integer :user_id
      t.string  :company
      t.string  :name
      t.string  :mobile
      t.decimal :online_rate, precision: 3, scale: 2, default: 0.0
      t.decimal :offline_rate, precision: 3, scale: 2, default: 0.0
      t.integer :state, default: 0

      t.timestamps null: false
    end
    UserRole.create(name: 'operator', display_name: "运营商")
  end
end
