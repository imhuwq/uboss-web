class RemoveBuyerPayFromProduct < ActiveRecord::Migration
  def change
    Product.all.each do |product|
      if product.buyer_pay
        product.transportation_way = 1
      else
        product.transportation_way = 0
      end
      product.save
    end
    remove_column :products, :buyer_pay, :boolean
  end
end
