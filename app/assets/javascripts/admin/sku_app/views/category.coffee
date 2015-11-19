class StockSku.Views.Category extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/category"]
  el: '#category'

  # events:
  #
  #
  # initialize: ->


  render: ->
    @$el.html @template()
    @
