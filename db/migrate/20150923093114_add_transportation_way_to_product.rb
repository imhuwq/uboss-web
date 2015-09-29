class AddTransportationWayToProduct < ActiveRecord::Migration
  def change
    add_column :products, :transportation_way, :integer, default: 0
  end
end
