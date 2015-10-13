class StockSku.Views.Sku extends Backbone.View

  collection: new StockSku.Collections.Properties

  el: '#product-sku'

  events:
    'click .add-property': 'addProperty'

  initialize: ->
    @listenTo @collection, 'add', @addOne
    @listenTo @collection, 'remove', @renderSku

  addProperty: (e) ->
    e.preventDefault()
    console.log 'add Property'
    newPropertyValues = new StockSku.Collections.PropertyValues
    newProperty = @collection.create(values: newPropertyValues)
    @listenTo newPropertyValues, 'add',    @renderSku
    @listenTo newPropertyValues, 'remove', @renderSku

  addOne: (property) =>
    propertyView = new StockSku.Views.Property(model: property, skuView: @)
    @.$('.property-list').append propertyView.render().el

  renderSku: ->
    console.log 'render stock'
    StockSku.stock_view.trigger('skuchange', @collection)
