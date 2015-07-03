class AddAddressAttrToUserAddress < ActiveRecord::Migration
  def change
    add_column :user_addresses, :area, :string
    add_column :user_addresses, :building, :string
  end
end

# UserAddress.create(
# user_id: 1,
#  username: "Jobs",
#  province: "广东省",
#  city: "深圳市",
#  country: "中国",
#  street: "粤海街道",
#  mobile: "13800000000",
#  default: true,
#  area: "南山区",
#  building: "深圳大学")