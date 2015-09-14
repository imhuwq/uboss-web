class CreateCarriageTemplates < ActiveRecord::Migration
  def change
    create_table :carriage_templates do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
