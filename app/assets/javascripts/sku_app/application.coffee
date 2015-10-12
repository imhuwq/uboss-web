#= require underscore-min
#= require backbone-min
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
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
