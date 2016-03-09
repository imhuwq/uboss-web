class SupplierProductInventory < ProductInventory

  validates :cost_price, presence: true, numericality: true
  validates_numericality_of :suggest_price_upper, greater_than: :suggest_price_lower,  if: -> { suggest_price_lower.present? and suggest_price_upper.present? }
  validates_numericality_of :suggest_price_lower, greater_than_or_equal_to: :cost_price, if: -> { suggest_price_lower.present? }

  belongs_to :supplier_product, foreign_key: 'product_id'
  has_many :children, class_name: 'AgencyProductInventory', foreign_key: 'parent_id'

  after_create :copy_to_children, if: -> { type == 'SupplierProductInventory' }
  after_destroy :remove_children
  after_update :update_child_count, if: -> { count_changed? }
  before_save :set_default_suggest_price_lower, unless: -> { suggest_price_lower.present? }
   
  amoeba do
    customize(lambda{|original_inventory, new_inventory|
      new_inventory.parent_id = original_inventory.id
      new_inventory.type = 'AgencyProductInventory'
      new_inventory.price = original_inventory.suggest_price_lower
    })
  end

  def adjust_count_with_checking(*args)
    transaction do
      adjust_count_without_checking(*args)
      if count.zero?
        children.update_all(count: 0, sale_to_customer: false)
      end
    end
  end
  alias_method_chain :adjust_count, :checking

  private
  # TODO 如果数量太多需要放入队列处理
  def copy_to_children
    supplier_product.children.each do |pro|
      amoeba_dup.update(product_id: pro.id, user_id: pro.user_id, sale_to_customer: false)
    end
  end

  def remove_children
    children.delete_all
  end

  def set_default_suggest_price_lower
    self.suggest_price_lower = self.cost_price
  end

  def update_child_count
    children.update_all(count: count, sale_to_customer: (count == 0 ? false : true))
  end

end
