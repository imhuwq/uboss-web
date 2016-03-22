class AddYdayToCooperations < ActiveRecord::Migration
  def change
    add_column :cooperations, :yday_performance, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :cooperations, :total_performance, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
