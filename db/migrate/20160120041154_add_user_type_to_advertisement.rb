class AddUserTypeToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :user_type, :string

    Advertisement.all.each do |adv|
      adv.user_type = 'Ordinary'
      adv.save
    end
  end
end
