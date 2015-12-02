class OrdinaryProduct < Product
  validate :must_has_one_product_inventory

  private

  def must_has_one_product_inventory
    errors.add(:product_inventories, '至少添加一个产品规格属性') unless product_inventories.size > 0
  end

end
