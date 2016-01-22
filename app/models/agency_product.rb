class AgencyProduct < OrdinaryProduct
  belongs_to :supplier_product
  has_many :agency_product_inventories, -> { where(type: 'AgencyProductInventory') }, foreign_key: 'product_id', autosave: true
  validates :parent_id, presence: true
end
