class CreateRegion < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
      t.string :numcode
      t.integer :parent_id
    end
  end
end
