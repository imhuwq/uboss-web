class ProductInventory.View.Properties extends Backbone.View

  template: JST["#{ProductInventory.TemplatesPath}/property"]
  tagName: 'div'
  className: 'buy_now_option'



  render: ->
  #    this.preventDefault()

   propertyCollection = new ProductInventory.Collections.Properties()
   hash = {'颜色':['红','白'],'尺寸':['L','XL']}

   for key,value of hash
     newPropertyValues = new ProductInventory.Collections.PropertyValues()
     for v of value
       newValue = new ProdectInventory.Models.PropertyValue(value: v)
       newPropertyValues.add(newValue)
     new ProdectInventory.Models.Property(name: key, values: newPropertyValues)
     propertyCollection.add(properties)
     console.log propertyCollection

   @properties = propertyCollection

   console.log "view", "ProductInventory.View.OutterBlock"
   @$el.html @template(properties: @properties)
   @
