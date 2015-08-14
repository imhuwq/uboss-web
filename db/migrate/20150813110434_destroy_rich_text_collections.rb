class DestroyRichTextCollections < ActiveRecord::Migration
  def change
    drop_table :rich_text_collections do |t|
      t.integer :resource_id
      t.string  :resource_type
      t.text    :content
    end
  end
end
