class StockSku.Views.StockItem extends Backbone.View

  tagName: 'tr'

  template: JST["#{StockSku.TemplatesPath}/stock_item"]

  initialize: ->
    @listenTo @model, "change", @render

  render: ->
    @$el.html @template(@model.toJSON())
    @
