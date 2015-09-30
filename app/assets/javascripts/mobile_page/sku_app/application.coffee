#= require underscore-min
#= require backbone-min
#= require_tree ./templates

data = [
  {title: 'A', content: 'A content'},
  {title: 'A', content: 'A content'},
  {title: 'A', content: 'A content'}
]
console.log JST["mobile_page/sku_app/templates/sku"](posts: data)
