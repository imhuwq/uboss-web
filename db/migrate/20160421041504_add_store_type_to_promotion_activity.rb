class AddStoreTypeToPromotionActivity < ActiveRecord::Migration
  def change
    add_column :promotion_activities, :store_type, :string, default: 'service'
  end
end
