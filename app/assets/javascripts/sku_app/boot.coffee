jQuery ($) ->

  if $('#product-sku').length > 0
    StockSku.Data.propertyData = window.propertyData
    StockSku.sku_view = new StockSku.Views.Sku
    StockSku.stock_view = new StockSku.Views.Stock
