class ModifySuggestPriceInSupplierProductInfos < ActiveRecord::Migration
  def change
    rename_column :supplier_product_infos, :suggest_price, :suggest_price_lower
    add_column :supplier_product_infos, :suggest_price_upper, :decimal
  end
end
