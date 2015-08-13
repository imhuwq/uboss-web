class RemoveProductsContent < ActiveRecord::Migration
  def change
    remove_column :products, :content, :text
  end
end
