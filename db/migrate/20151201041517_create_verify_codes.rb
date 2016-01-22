class CreateVerifyCodes < ActiveRecord::Migration
  def change
    create_table :verify_codes do |t|
      t.string :code
      t.boolean :verified, default: false

      t.timestamps null: false
    end
  end
end
