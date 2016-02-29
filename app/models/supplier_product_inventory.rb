class SupplierProductInventory < ProductInventory

  validates_numericality_of :suggest_price_upper, greater_than: :suggest_price_lower,  if: -> { suggest_price_lower.present? }
  validates_numericality_of :suggest_price_lower, greater_than_or_equal_to: :cost_price, if: -> { cost_price.present? }

  belongs_to :supplier_product, foreign_key: 'product_id'
  has_many :children, class_name: 'AgencyProductInventory', foreign_key: 'parent_id'
  after_create :copy_to_children, if: -> { type == 'SupplierProductInventory' }
  after_destroy :remove_children

  amoeba do
    customize(lambda{|original_inventory, new_inventory|
      new_inventory.parent_id = original_inventory.id
      new_inventory.type = 'AgencyProductInventory'
      new_inventory.cost_price = original_inventory.price
    })
  end

  private
  # TODO 如果数量太多需要放入队列处理
  def copy_to_children
    supplier_product.children.each do |pro|
      amoeba_dup.update(product_id: pro.id, user_id: pro.user_id, saling: false)
    end
  end

  def remove_children
    children.delete_all
  end
end
