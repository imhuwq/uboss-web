class AddCarriageTemplateIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :carriage_template_id, :integer
  end
end
