class CreateRichTextCollections < ActiveRecord::Migration
  def change
     create_table :rich_text_collections do |t|
       t.integer :resource_id
      t.string  :resource_type
       t.text    :content
     end
  end

end
