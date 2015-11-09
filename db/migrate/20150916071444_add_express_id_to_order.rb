class AddExpressIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :express_id, :integer
  end
end
