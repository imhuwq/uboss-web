class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.string   :content_type
      t.string   :resource_type, limit: 50
      t.integer  :resource_id
      t.integer  :integer_count
      t.decimal  :decimal_count
      t.jsonb    :resource_message
      t.timestamps null: false
    end
  end
end
