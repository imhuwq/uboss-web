class StockSku.Collections.Properties extends Backbone.Collection

  model: StockSku.Models.Property

  available: ->
    @.filter (property) ->
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
