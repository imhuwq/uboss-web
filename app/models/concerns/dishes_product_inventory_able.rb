module DishesProductInventoryAble
  extend ActiveSupport::Concern

  included do
    after_initialize :set_count, if: :it_was_dishes_product_inventory?

    def set_count
      self.count = 1_000_000
    end

    def it_was_dishes_product_inventory?
      product.type == 'DishesProduct'
    end
  end
end