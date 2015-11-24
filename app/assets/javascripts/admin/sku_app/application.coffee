#= require underscore-min
#= require backbone-min
#= require_self
#= require_tree ./templates
#= require ./models/property_value
#= require ./collections/property_values
#= require ./models/property
#= require ./collections/properties
#= require ./models/stock
#= require ./collections/stocks
#= require ./models/category_select_option
#= require ./collections/category_select_options
#= require_tree ./views
#= require ./boot

((root) ->

  # disable backbone sync
  Backbone.sync = ->
    return false

  StockSku =
    TemplatesPath: 'admin/sku_app/templates'
    Data: {}
    Views: {}
    Models: {}
    Collections: {}

  root.StockSku = StockSku

)(window)
