class SupplierProductInventory < ProductInventory

  belongs_to :supplier_product
  has_many :agency_product_inventories, foreign_key: 'parent_id'

  amoeba do
    customize(lambda{|original_inventory, new_inventory|
      new_inventory.parent_id = original_inventory.id
      new_inventory.type = 'AgencyProductInventory'
      new_inventory.cost_price = original_inventory.price
    })
  end

end
