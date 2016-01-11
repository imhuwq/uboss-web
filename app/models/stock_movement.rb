class StockMovement < ActiveRecord::Base
  belongs_to :product_inventory, inverse_of: :stock_movements
  belongs_to :originator, polymorphic: true

  validates :product_inventory, presence: true
  validates :quantity, presence: true, numericality: {
               greater_than_or_equal_to: -2**31,
               less_than_or_equal_to: 2**31-1,
               only_integer: true,
               allow_nil: true
            }

  enum action: { sale: 1, purchase: 2, return: 3, adjustment: 4 }  # 销售出入库 购买(分销)出入库 退货出入库 调整出入库

  after_create :update_stock_item_quantity

  def self.unstock(product_inventory, quantity)
    create!(product_inventory: product_inventory, quantity: quantity)
  end

  private
  def update_stock_item_quantity
    product_inventory.adjust_count quantity
  end
end
