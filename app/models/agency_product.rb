class AgencyProduct < OrdinaryProduct
  belongs_to :supplier_product
  belongs_to :supplier, foreign_key: 'supplier_id', class_name: 'User'
  has_many :agency_product_inventories, -> { where(type: 'AgencyProductInventory') }, foreign_key: 'product_id', autosave: true
end
