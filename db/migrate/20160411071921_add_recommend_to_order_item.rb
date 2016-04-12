class AddRecommendToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :recommend, :boolean, default: false
  end
end
