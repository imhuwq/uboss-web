module Fenxiao::OrderItem
  extend ActiveSupport::Concern

  included do
    validate :ensure_sku_in_sale, on: :create

    private

    def ensure_sku_in_sale
      errors.add(:base, "商品已失效") if !product_inventory.saling?
    end
  end
end