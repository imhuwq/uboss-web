class AddUserTypeToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :user_type, :string

    Advertisement.update_all(user_type: 'Ordinary')
  end
end
