class StockSku.Views.Stock extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/stock"]

  el: '#product-stock'

  initialize: ->
    @listenTo @, 'skuchange', @render

  stock_cache: []

  render: ->
    skuCollection = StockSku.Collections.property_collection
    if skuCollection?
      console.log 'rendering stock group view with sku collection'
      property_counter = []
      stockSkuCollection = []
      skuCollection.each (item)->
        length = item.get('values').length
        if length > 0
          property_counter.push(length)
          stockSkuCollection.push(item)
      stock_length = 1
      _.each property_counter, (p_count) ->
        stock_length *= p_count
      propertys = stockSkuCollection.map (item)-> item.get('name')

      @.$('.stock-list').html @template(propertys: propertys)

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
        stockItemCacheIndex = _.findIndex @stock_cache, {id: stockIdentify}
        if stockItemCacheIndex == -1
          stockItemModel = @collection.findWhere(identify: stockIdentify)
          unless stockItemModel?
            @collection.add(id: skuPVId + stockIndex,sku_attributes: skuAttrs)
          stockItemView = new StockSku.Views.StockItem(model: stockItemModel)
          @stock_cache.push(id: stockIdentify, view: stockItemView)
        else
          stockItemView = @stock_cache[stockItemCacheIndex].view
        @.$('table#stock-group tbody').append stockItemView.render().el

      #property_length: stockSkuCollection.length
      #stock_length: stock_length
      #getPVInputName: (pvIndex, skuPVId) ->
        #"product[product_inventories_attributes][#{skuPVId}][sku_attributes][#{propertys[pvIndex - 1]}]"
      #getPVByIndex: (stockIndex, pvIndex) ->
        #groupTotal = 1
        #_.each property_counter.slice(pvIndex, property_counter.length), (totalPv)->
          #groupTotal *= totalPv
        #if groupTotal == 1
          #getPVIndex = stockIndex % property_counter[pvIndex-1]
          #getPVIndex = property_counter[pvIndex-1] if getPVIndex == 0
        #else
          #getPVIndex = parseInt((stockIndex-1)/groupTotal) % property_counter[pvIndex - 1]
        #console.log "stockIndex: #{stockIndex}, pvIndex: #{pvIndex}, groupTotal: #{groupTotal}, getPVIndex:#{getPVIndex}"
        #property = stockSkuCollection[pvIndex-1].get('values').at(getPVIndex-1).get('value')
