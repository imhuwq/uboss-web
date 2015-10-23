class StockSku.Views.StockItem extends Backbone.View

  tagName: 'tr'

  template: JST["#{StockSku.TemplatesPath}/stock_item"]

  events:
    'blur input.sku-price': 'setPrice'
    'blur input.sku-count': 'setCount'

  initialize: ->
    @listenTo @model, "change", @render

  render: ->
    @$el.html @template(@model.toJSON())
    @

  setPrice: (e)->
    @model.attributes['price'] = $(e.target).val()

  setCount: (e)->
    @model.attributes['count'] = $(e.target).val()
    if @model.collection?
      total = @model.collection.reduce (num, item)->
        Number(item.get('count')) + num
      , 0
      $('#product_count').val(total)
