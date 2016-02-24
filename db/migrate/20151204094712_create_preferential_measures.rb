class CreatePreferentialMeasures < ActiveRecord::Migration
  def change
    create_table :preferential_measures do |t|
      t.decimal :amount
      t.decimal :discount
      t.decimal :total_amount
      t.string  :type
      t.belongs_to :preferential_item, polymorphic: true
      t.belongs_to :preferential_source, polymorphic: true

      t.timestamps null: false
    end
  end
end
