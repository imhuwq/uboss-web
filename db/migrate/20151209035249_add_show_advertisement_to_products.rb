class AddShowAdvertisementToProducts < ActiveRecord::Migration
  def change
  	add_column :products, :show_advertisement, :boolean,  default: false
  end
end
