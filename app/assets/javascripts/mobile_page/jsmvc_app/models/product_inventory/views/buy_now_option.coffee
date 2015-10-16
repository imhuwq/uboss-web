class ProductInventory.View.BuyNowOption extends Backbone.View

  template: JST["#{ProductInventory.TemplatesPath}/buy_now_option"]

  className: "buy_now_option"

  el: "#product_inventory_options"

  events:
    'click div': 'alertSome'


  render: ->

    # 写入（model生成模式）
    propertyCollection = new ProductInventory.Collections.Properties
    hash = {'颜色':['红','白'],'尺寸':['L','XL']}
    for key,value of hash
      newPropertyValues = new ProductInventory.Collections.PropertyValues
      for v in value
        console.log "for v of value", v
        newValue = new ProductInventory.Models.PropertyValue(property_value: v)
        newPropertyValues.add(newValue)

      newProperty = new ProductInventory.Models.Property(name: key, property_values: newPropertyValues)
      propertyCollection.add(newProperty)

    # 读出（model生成模式）

    $('#product_inventory_options').html @template()
    # @$el.html @template()

    propertyCollection.each (propertyModel) ->
      propertyView = new ProductInventory.View.Property(model: propertyModel)
      $('#product_inventory_options .buy_now_option').append propertyView.render().el
      # console.log "$(@$el).find('.buy_now_option')", $(@$el).find('.buy_now_option').html()
      # $(@$el).find('.buy_now_option').append propertyView.render().el
      propertyModel.get('property_values').each (value) ->
        propertyValueModel = new ProductInventory.Models.PropertyValue(value: value.get('property_value' ))
        parentPorperty = $('#product_inventory_options').find("##{propertyModel.cid}")
        parentPorperty.find('ul').append new ProductInventory.View.PropertyValue(model: propertyValueModel).render().el

    @

  alertSome: ->
    console.log "alertSome"
#    e.addClass('item_click')
#  event: ->
#    $('#product_inventory_options .sku').on 'click', this.addClass('item_click'),this
