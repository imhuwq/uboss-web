class StockSku.Views.Stock extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/stock"]

  el: '#product-stock'

  read_only: false

  initialize: ->
    @listenTo @collection, 'skuchange', @render
    @listenTo @, 'initShow', @renderShow

  stockCache: []

  renderShow: ->
    console.log 'render_show'
    @read_only = true
    @render()

  render: ->
    skuCollection = StockSku.Collections.property_collection
    return @ unless skuCollection?

    console.log 'rendering stock group view with sku collection'
    stockSkuCollection = skuCollection.available()
    property_counter = stockSkuCollection.map (item)-> item.get('values').length

    stock_length = 1
    _.each property_counter, (p_count) ->
      stock_length *= p_count
    propertys = stockSkuCollection.map (item)-> item.get('name')
    @.$('.stock-list').html @template(propertys: propertys)

    return @ unless stockSkuCollection.length > 0
    skuPVId = new Date().getTime()
    for stockIndex in [1..stock_length]
      skuAttrs = {}
      for pvIndex in [1..stockSkuCollection.length]
        pValue = do (stockIndex, pvIndex) ->
          groupTotal = 1
          _.each property_counter.slice(pvIndex, property_counter.length), (totalPv)->
            groupTotal *= totalPv
          if groupTotal == 1
            getPVIndex = stockIndex % property_counter[pvIndex-1]
            getPVIndex = property_counter[pvIndex-1] if getPVIndex == 0
          else
            getPVIndex = parseInt((stockIndex-1)/groupTotal) % property_counter[pvIndex - 1]
          console.log "stockIndex: #{stockIndex}, pvIndex: #{pvIndex}, groupTotal: #{groupTotal}, getPVIndex:#{getPVIndex}"
          property = stockSkuCollection[pvIndex-1].get('values').at(getPVIndex-1).get('value')
        pName  = propertys[pvIndex - 1]
        skuAttrs[pName] = pValue
      stockIdentify = JSON.stringify(skuAttrs)
      stockItemCacheIndex = _.findIndex @stockCache, {id: stockIdentify}
      if stockItemCacheIndex == -1
        stockItemModel = @collection.findWhere(identify: stockIdentify)
        unless stockItemModel?
          stockItemModel = @collection.add(id: skuPVId + stockIndex,sku_attributes: skuAttrs)
        stockItemModel.set('read_only', @read_only)
        stockItemView = new StockSku.Views.StockItem(model: stockItemModel)
        console.log('new stockItemModel')
        @stockCache.push(id: stockIdentify, view: stockItemView)
        @.$('table#stock-group tbody').append stockItemView.render().el
      else
        stockItemView = @stockCache[stockItemCacheIndex].view
        @.$('table#stock-group tbody').append stockItemView.el
    @
