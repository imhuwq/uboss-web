#class ProductInventory.View.Properties extends Backbone.View
#
#  template: JST["#{ProductInventory.TemplatesPath}/buy_now_option"]
#  tagName: 'div'
#  className: 'buy_now_option'
#  id: 233
#
#
#  initialize: ->
#    collection: @collection
#
#
#  render: ->
#    console.log "view", "ProductInventory.View.Properties"
#    #    this.preventDefault()
#    propertyCollection = new ProductInventory.Collections.Properties
#    hash = {'颜色':['红','白'],'尺寸':['L','XL']}
#
#
#    # 写入
#    for key,value of hash
#      newPropertyValues = new ProductInventory.Collections.PropertyValues
#      console.log "for key,value of hash", key,value
#      for v in value
#        console.log "for v of value", v
#        newValue = new ProductInventory.Models.PropertyValue(property_value: v)
#        newPropertyValues.add(newValue)
#
#      newProperty = new ProductInventory.Models.Property(name: key, property_values: newPropertyValues)
#      propertyCollection.add(newProperty)
#
#
#    console.log "propertyCollection",propertyCollection
#
#    # 读出
#    propertyViews = new ProductInventory.View.Properties
#    property_str = ""
#    propertyCollection.each (property) ->
#      propertyValue_str = ""
#      property.get('property_values').each (value) ->
#        propertyValueModel = new ProductInventory.Models.PropertyValue(value: value.get('property_value' ))
#        propertyValue_str += JST["#{ProductInventory.TemplatesPath}/property_value"](property_value: propertyValueModel.get('value'), cid: propertyValueModel.get('cid'))
#
#      property_str += JST["#{ProductInventory.TemplatesPath}/property"]( property_name: property.get('name'), property_views: propertyValue_str )
#
#
#    @$el.html @template(properites: property_str)
#    @
#
#
#
#
#    @$el.html @template(properites: property_str)
#    @
