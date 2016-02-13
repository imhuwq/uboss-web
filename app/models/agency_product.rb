class AgencyProduct < OrdinaryProduct
  belongs_to :parent, class_name: 'SupplierProduct'
  belongs_to :supplier, foreign_key: 'supplier_id', class_name: 'User'
  has_many :agency_product_inventories, -> { where(type: 'AgencyProductInventory') }, foreign_key: 'product_id', autosave: true
  validates :parent_id, presence: true
end
