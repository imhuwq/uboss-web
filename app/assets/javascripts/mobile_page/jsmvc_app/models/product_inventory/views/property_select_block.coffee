class ProductInventory.View.PropertySelectBlock extends Backbone.View

  template: JST["#{ProductInventory.TemplatesPath}/property_select_block"]
  collection: new ProductInventory.Collections.Properties
  tagName: 'div'
  className: 'buy_now_option'


  render:() ->
    # this.preventDefault()
    properties = new ProductInventory.Collections.Properties
    console.log "view", "ProductInventory.View.OutterBlock"
    @$el.html @template(product_property: 'product_property')
    @
