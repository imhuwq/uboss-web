class StockSku.Views.Stock extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/stock"]

  el: '#product-stock'

  read_only: false

  initialize: ->
    @listenTo @collection, 'skuchange', @render
    @listenTo @, 'initShow', @renderShow

  stockCache: []

  propertyCollection: ->
    StockSku.Collections.property_collection

  renderShow: ->
    console.log 'render_show'
    @read_only = true
    @render()

  render: ->
    skuCollection = StockSku.Collections.property_collection
    return @ unless skuCollection?

    console.log 'rendering stock group view with sku collection'
    stockSkuCollection = skuCollection.available()
    propertys = stockSkuCollection.map (item)-> item.get('name')
    @.$('.stock-list').html @template(propertys: propertys)

    @clearStockCache()
    @stockCache = []
    @propertyCollection().renderStockItems(@renderStockItemView.bind(@))

  renderStockItemView: (skuAttrs)->
    skuPVId = new Date().getTime()
    stockIdentify = JSON.stringify(skuAttrs)
    stockItemModel = @collection.findWhere(identify: stockIdentify)
    unless stockItemModel?
      console.log('new stockItemModel')
      stockItemModel = @collection.add(id: skuPVId + parseInt(Math.random() * 1000), sku_attributes: skuAttrs)
    stockItemModel.set('read_only', @read_only)
    stockItemView = new StockSku.Views.StockItem(model: stockItemModel)
    @stockCache.push(stockItemView)
    @.$('table#stock-group tbody').append stockItemView.render().el
    @

  clearStockCache: ->
    _.each @stockCache, (view) -> view.remove()
