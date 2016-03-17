class AddOrdinaryStoreIdToOrdinaryProduct < ActiveRecord::Migration
  def change
    add_column :products, :ordinary_store_id, :integer
    # OrdinaryProduct.all.each do |o_product|
    #   o_product.ordinary_store = o_product.user.ordinary_store
    #   o_product.save
    # end
  end
end
