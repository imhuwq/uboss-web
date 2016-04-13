class CreateCallingNotifies < ActiveRecord::Migration
  def change
    create_table :calling_notifies do |t|
      t.references :user,            index: true, foreign_key: true
      t.references :table_number,    index: true, foreign_key: true
      t.references :calling_service, index: true, foreign_key: true
      t.datetime   :called_at
      t.integer    :status, default: 0

      t.timestamps null: false
    end
  end
end
