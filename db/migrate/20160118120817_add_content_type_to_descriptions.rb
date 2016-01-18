class AddContentTypeToDescriptions < ActiveRecord::Migration
  def change
    add_column :descriptions, :content_type, :string
    if index_exists?(:descriptions, [:resource_type, :resource_id])
      remove_index :descriptions, [:resource_type, :resource_id]
      add_index :descriptions, [:resource_type, :resource_id, :content_type], name: 'index_description_uniq_resouce_relate'
    end
  end
end
