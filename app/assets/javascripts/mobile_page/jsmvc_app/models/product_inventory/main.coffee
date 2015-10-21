#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views

console.log "main is ready"

((root) ->

  # disable backbone sync
  Backbone.sync = ->
    return false

  ProductInventory =
    TemplatesPath: 'mobile_page/jsmvc_app/models/product_inventory/templates'
    Data: {}
    Views: {}
    Models: {}
    Collections: {}

  root.ProductInventory = ProductInventory

)(window)

ProductInventory.View = Backbone.View.extend()
ProductInventory.Collections.Properties = Backbone.Collection.extend()
