class ProductInventory.View.PriceRange extends Backbone.View
  
  el: "#price_range"
  price_range: 0

  render: (price) ->
    @price_range = price
    $('#price_range').html @price_range
