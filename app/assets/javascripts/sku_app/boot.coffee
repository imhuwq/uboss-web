jQuery ($) ->

  if $('#product-sku').length > 0
    StockSku.Data.propertyData = window.propertyData
    StockSku.sku_view = new StockSku.Views.Sku
