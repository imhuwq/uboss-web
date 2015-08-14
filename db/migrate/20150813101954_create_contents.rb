class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.integer :resource_id
      t.string  :resource_type
      t.text    :content
    end
  end
end
