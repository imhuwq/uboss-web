#= require underscore-min
#= require backbone-min
#= require_self
#= require_tree ./templates
#= require sku_app/models/property_value
#= require sku_app/collections/property_values
#= require sku_app/models/property
#= require sku_app/collections/properties
#= require sku_app/models/stock
#= require sku_app/collections/stocks
#= require_tree ./views
#= require sku_app/boot

((root) ->

  # disable backbone sync
  Backbone.sync = ->
    return false

  StockSku =
    TemplatesPath: 'sku_app/templates'
    Data: {}
    Views: {}
    Models: {}
    Collections: {}

  root.StockSku = StockSku

)(window)
