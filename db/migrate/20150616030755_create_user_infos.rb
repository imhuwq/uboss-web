class CreateUserInfos < ActiveRecord::Migration
  def change
    create_table :user_infos do |t|
      t.belongs_to :user
      t.float :income
      t.float :income_level_one
      t.float :income_level_two
      t.float :income_level_thr
      t.float :sharing_counter

      t.timestamps null: false
    end

    add_foreign_key :user_infos, :users, on_delete: :nullify
  end
end
