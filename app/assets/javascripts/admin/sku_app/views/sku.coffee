class StockSku.Views.Sku extends Backbone.View

  el: '#product-sku'

  events:
    'click .add-property': 'addProperty'

  initialize: ->
    @listenTo @collection, 'add', @addOne
    @listenTo @collection, 'remove', @renderSku
    if @collection.length > 0
      @addAll()
      @renderSku()

  addProperty: (e) ->
    e.preventDefault()
    console.log 'add Property'
    newProperty = @collection.create(values: new StockSku.Collections.PropertyValues)
    newPropertyValues = newProperty.get('values')
    #@listenTo newPropertyValues, 'add',    @renderSku
    @listenTo newPropertyValues, 'remove', @renderSku

  addAll: ->
    @collection.each (property) =>
      propertyValues = property.get('values')
      #@listenTo propertyValues, 'add',    @renderSku
      @listenTo propertyValues, 'remove', @renderSku
      @addOne(property)

  addOne: (property) =>
    propertyView = new StockSku.Views.Property(model: property, skuView: @)
    @.$('.property-list').append propertyView.render().el
    if property.get('values').length > 0
      propertyView.addAllPropertyValue()
    else
      propertyView.trigger('openSelect')

  renderSku: ->
    console.log 'render stock'
    StockSku.stock_view.trigger('skuchange')
