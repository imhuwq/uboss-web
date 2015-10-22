class StockSku.Collections.Properties extends Backbone.Collection

  model: StockSku.Models.Property

  available: ->
    @.filter (property) ->
      property.get('values').length > 0
