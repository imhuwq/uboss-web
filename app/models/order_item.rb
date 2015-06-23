class OrderItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :order
  belongs_to :product
  belongs_to :sharing_node

  delegate :name, to: :product, prefix: true

  after_create :decrease_product_stock

  def recover_product_stock
    adjust_product_stock(1)
  end

  def decrease_product_stock
    adjust_product_stock(-1)
  end

  private

  def adjust_product_stock(type)
    if [1, -1].include?(type)
      Product.update_counters(product_id, count: amount * type)
    else
      raise 'Accept value is -1 or 1'
    end
  end

end
