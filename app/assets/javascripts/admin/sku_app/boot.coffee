jQuery ($) ->

  if $('#product-sku').length > 0 || $('#product-stock').length > 0
    console.log 'boot skuapp'
    skuPVId = new Date().getTime()
    _.each window.stockData, (data) ->
      if not data.id?
        data.id = skuPVId
        skuPVId += 1
    StockSku.Data.propertyData = window.propertyData
    StockSku.Data.stockData = window.stockData

    StockSku.Collections.stock_collection    = new StockSku.Collections.Stock(stockData)
    StockSku.Collections.property_collection = new StockSku.Collections.Properties()

    window.propertieCollectionData = {}
    if StockSku.Collections.stock_collection.length > 0
      properties = StockSku.Collections.stock_collection.first().get('sku_attributes')
      console.log "Boot: properties", properties
      for key of properties
        console.log "Boot: add #{key} to Properties"
        StockSku.Collections.property_collection.add
          name: key
          values: new StockSku.Collections.PropertyValues
        propertieCollectionData[key] = []

      StockSku.Collections.stock_collection.each (stockItem) ->
        skuAttrs = stockItem.get('sku_attributes')
        for key of skuAttrs
          propertyItem = StockSku.Collections.property_collection.findWhere(name: key)
          if propertyItem?
            console.log "Boot: add value #{skuAttrs[key]} to Propertie #{key}"
            propertyItem.get('values').add(value: skuAttrs[key])
            propertieCollectionData[key].push(skuAttrs[key])

    if $('#product-sku').length > 0
      StockSku.stock_view = new StockSku.Views.Stock(collection: StockSku.Collections.stock_collection, type: 'agency')
      StockSku.privilege_view = new StockSku.Views.Privilege(collection: StockSku.Collections.stock_collection)
      StockSku.sku_view = new StockSku.Views.Sku(collection: StockSku.Collections.property_collection)

    else if $('#product-stock').length > 0
      StockSku.stock_view = new StockSku.Views.Stock(collection: StockSku.Collections.stock_collection, type: 'agency')
      StockSku.privilege_view = new StockSku.Views.Privilege(collection: StockSku.Collections.stock_collection)
      StockSku.stock_view.trigger('initShow')
      StockSku.privilege_view.trigger('initShow')


  if $('#category').length > 0
    category = new StockSku.Views.Category
    category.render()
