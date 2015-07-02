class CreateServiceNotifies < ActiveRecord::Migration
  def change
    create_table :service_notifies do |t|
      t.string :service_type
      t.text :content

      t.timestamps null: false
    end
  end
end
