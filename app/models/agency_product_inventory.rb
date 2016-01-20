class AgencyProductInventory < ProductInventory
  belongs_to :supplier_product_inventory
  belongs_to :agency_product
end
