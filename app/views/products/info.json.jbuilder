# Example
# {
#     "份量" => {
#         "大" => ":85:86:87:88:89:90:91:92:93",
#         "中" => ":94:95:96:97:98:99:100:101:102",
#         "小" => ":103:104:105:106:107:108:109:110:111"
#     },
#     "工艺" => {
#         "10" => ":85:88:91:94:97:100:103:106:109",
#         "20" => ":86:89:92:95:98:101:104:107:110",
#         "30" => ":87:90:93:96:99:102:105:108:111"
#     },
#     "调料" => {
#          "葱" => ":85:86:87:94:95:96:103:104:105",
#         "花生" => ":88:89:90:97:98:99:106:107:108",
#         "牛肉" => ":91:92:93:100:101:102:109:110:111"
#     }
# }
h=Hash.new {|k,v| k[v] = Hash.new {|x,y| x[y] = ""} }
skus = @product.product_inventories.reduce(h) do |s, inv|
  inv.sku_attributes.each do |k,v|
    s[k][v] << ":#{inv.id}"
  end
  s
end

# Example
# [
#   {
#                 :id => 85,
#         :properties => "份量:大;工艺:10;调料:葱",
#              :count => 90000,
#              :price => 20.0
#   },
#   {
#                 :id => 86,
#         :properties => "份量:大;工艺:20;调料:葱",
#              :count => 90000,
#              :price => 25.0
#   },
#   {
#                 :id => 87,
#         :properties => "份量:大;工艺:30;调料:葱",
#              :count => 90000,
#              :price => 30.0
#   },
#   {
#                 :id => 88,
#         :properties => "份量:大;工艺:10;调料:花生",
#              :count => 90000,
#              :price => 20.0
#   },
#   {
#                 :id => 89,
#         :properties => "份量:大;工艺:20;调料:花生",
#              :count => 90000,
#              :price => 25.0
#   },
#   {
#                 :id => 90,
#         :properties => "份量:大;工艺:30;调料:花生",
#              :count => 90000,
#              :price => 30.0
#   },
#   {
#                 :id => 91,
#         :properties => "份量:大;工艺:10;调料:牛肉",
#              :count => 90000,
#              :price => 20.0
#   },
#   {
#                 :id => 92,
#         :properties => "份量:大;工艺:20;调料:牛肉",
#              :count => 90000,
#              :price => 25.0
#   },
#   {
#                 :id => 93,
#         :properties => "份量:大;工艺:30;调料:牛肉",
#              :count => 90000,
#              :price => 30.0
#   },
#   {
#                 :id => 94,
#         :properties => "份量:中;工艺:10;调料:葱",
#              :count => 90000,
#              :price => 15.0
#   },
#   {
#                 :id => 95,
#         :properties => "份量:中;工艺:20;调料:葱",
#              :count => 90000,
#              :price => 20.0
#   },
#   {
#                 :id => 96,
#         :properties => "份量:中;工艺:30;调料:葱",
#              :count => 90000,
#              :price => 25.0
#   },
#   {
#                 :id => 97,
#         :properties => "份量:中;工艺:10;调料:花生",
#              :count => 90000,
#              :price => 15.0
#   },
#   {
#                 :id => 98,
#         :properties => "份量:中;工艺:20;调料:花生",
#              :count => 90000,
#              :price => 20.0
#   },
#   {
#                 :id => 99,
#         :properties => "份量:中;工艺:30;调料:花生",
#              :count => 90000,
#              :price => 25.0
#   },
#   {
#                 :id => 100,
#         :properties => "份量:中;工艺:10;调料:牛肉",
#              :count => 90000,
#              :price => 15.0
#   },
#   {
#                 :id => 101,
#         :properties => "份量:中;工艺:20;调料:牛肉",
#              :count => 90000,
#              :price => 20.0
#   },
#   {
#                 :id => 102,
#         :properties => "份量:中;工艺:30;调料:牛肉",
#              :count => 90000,
#              :price => 25.0
#   },
#   {
#                 :id => 103,
#         :properties => "份量:小;工艺:10;调料:葱",
#              :count => 90000,
#              :price => 10.0
#   },
#   {
#                 :id => 104,
#         :properties => "份量:小;工艺:20;调料:葱",
#              :count => 90000,
#              :price => 15.0
#   },
#   {
#                 :id => 105,
#         :properties => "份量:小;工艺:30;调料:葱",
#              :count => 90000,
#              :price => 20.0
#   },
#   {
#                 :id => 106,
#         :properties => "份量:小;工艺:10;调料:花生",
#              :count => 90000,
#              :price => 10.0
#   },
#   {
#                 :id => 107,
#         :properties => "份量:小;工艺:20;调料:花生",
#              :count => 90000,
#              :price => 15.0
#   },
#   {
#                 :id => 108,
#         :properties => "份量:小;工艺:30;调料:花生",
#              :count => 90000,
#              :price => 20.0
#   },
#   {
#                 :id => 109,
#         :properties => "份量:小;工艺:10;调料:牛肉",
#              :count => 90000,
#              :price => 10.0
#   },
#   {
#                 :id => 110,
#         :properties => "份量:小;工艺:20;调料:牛肉",
#              :count => 90000,
#              :price => 15.0
#   },
#   {
#                 :id => 111,
#         :properties => "份量:小;工艺:30;调料:牛肉",
#              :count => 90000,
#              :price => 20.0
#   }
# ]
items = @product.product_inventories.reduce([]) do |s, i|
  s << {id: i.id, properties: i.sku_attributes_str, count: i.count, price: i.price }
end
json.id     @product.id
json.skus   skus
json.img    @product.asset_img
json.name   @product.name
json.price  @product.present_price
json.items  items