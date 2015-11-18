class StockSku.Collections.Properties extends Backbone.Collection

  model: StockSku.Models.Property

  available: ->
    @filter (property) ->
      property.get('values').length > 0

  propertyCounter: ->
    @available().map (item)-> item.get('values').length

  propertyGroupCounter: ->
    groupCounter = []
    propertyCounter = @propertyCounter()
    _.each propertyCounter, (__, pcIndex) ->
      groupTotal = 1
      _.each propertyCounter.slice(pcIndex+1, propertyCounter.length), (totalPv)->
        groupTotal *= totalPv
      groupCounter.push(groupTotal)
    groupCounter

  propertys: ->
    @available().map (item)-> item.get('name')

  renderStockItems: (renderFunc) ->
    availableCollection = @available()
    return @ if availableCollection.length == 0
    propertyGroupCounter = @propertyGroupCounter()
    @renderStockItem(availableCollection, propertyGroupCounter, renderFunc)
    @

  renderStockItem: (skuCollection, propertyGroupCounter, renderFunc, skuIndex = 0, skuAttrs = {})->
    property = skuCollection[skuIndex]
    propertyValues = property.get('values')
    propertyType = property.get('name')
    propertyValues.each (propertyValue) =>
      skuAttrs[propertyType] = propertyValue.get('value')
      groupTotal = propertyGroupCounter[skuIndex]
      if skuIndex == propertyGroupCounter.length - 1
        renderFunc(skuAttrs)
      else
        @renderStockItem(skuCollection, propertyGroupCounter, renderFunc, skuIndex+1, skuAttrs)
    @
