class CreatePlatformAdvertisements < ActiveRecord::Migration
  def change
    create_table :platform_advertisements do |t|
    	t.string  :advertisement_url
    	t.integer :status, default: 0
    	t.timestamps null: false
    end
  end
end
