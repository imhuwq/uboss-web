class StockSku.Views.Sku extends Backbone.View

  collection: new StockSku.Collections.Properties

  el: '#product-sku'

  events:
    'click .add-property': 'addProperty'

  initialize: ->
    @collection.bind 'reset', =>
      @addAll()
    @collection.bind 'add', (property) =>
      @addOne(property)

  addProperty: (e) ->
    e.preventDefault()
    console.log 'addProperty'
    newPropertyValues = new StockSku.Collections.PropertyValues
    newProperty = @collection.create(values: newPropertyValues)
    @listenTo newProperty, 'destroy', @propertyDestoryed
    @listenTo newPropertyValues, 'add', @renderSku
    @listenTo newPropertyValues, 'remove', @renderSku

  addOne: (property) =>
    propertyView = new StockSku.Views.Property(model: property, skuView: @)
    @.$('.property-list').append propertyView.render().el

  addAll: =>
    @collection.each @addOne, @

  renderSku: ->
    console.log 'renderSKU'

  propertyDestoryed: ->
    console.log 'remove one property in sku'
