class OrderItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :order
  belongs_to :product
  belongs_to :sharing_node

  delegate :name, to: :product, prefix: true

  after_create :decrease_product_stock

  private

  def decrease_product_stock
    Product.update_counters(product_id, count: -1)
  end

end
