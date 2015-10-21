class ProductInventory.Models.Inventory extends Backbone.Model


  defaults:
    count: '0'


  template: JST["#{ProductInventory.TemplatesPath}/property"]




  # render: ->
  #   propertyCollection = new ProductInventory.Collections.Properties
  #   hash = {'颜色':['红','白'],'尺寸': ['L','XL']}
  #   for key,value of hash
  #     newPropertyValues = new ProductInventory.Collections.PropertyValues
  #     for v of value
  #       newValue = new ProductInventory.Models.PropertyValue(value: v)
  #       newPropertyValues.add(newValue)
  #     new ProductInventory.Models.Property(name: k, values: newPropertyValues)
  #     propertyCollection.add(properties)
  #     console.log propertyCollection
  #
  #   @properties = propertyCollection
