class TryRemoveProductContentColumn < ActiveRecord::Migration
  def up
    if Product.column_names.include?('content')
      remove_column :products, :content
    end
  end

  def down
    add_column :products, :content, :text
  end
end
