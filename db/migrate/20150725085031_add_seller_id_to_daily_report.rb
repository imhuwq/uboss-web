class AddSellerIdToDailyReport < ActiveRecord::Migration
  def change
    add_column :daily_reports, :seller_id, :integer
  end
end
