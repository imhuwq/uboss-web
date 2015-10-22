class StockSku.Models.Stock extends Backbone.Model

  idAttribute: 'identify'

  initialize: ->
    @set('identify', JSON.stringify(@get('sku_attributes')))

  default:
    sku_attributes: {}
    count: 0
    price: 0
