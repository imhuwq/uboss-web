class ProductInventory.View.BuyNowOption extends Backbone.View

  template: JST["#{ProductInventory.TemplatesPath}/buy_now_option"]

  className: "buy_now_option"

  el: "#product_inventory_options"

  properties: null;

  initialize: ->
    @properties = @getProperties()

  events:
    'click .sku': 'selectSkuItem'


  getProperties: (product_id)->
    # 写入（model生成模式）
    propertyCollection = new ProductInventory.Collections.Properties
    skuCollection = ProductInventory.Collections.SKUs
    sku_list = {1:{count: 100,sku_attributes: {'颜色':'红','尺寸':'XL'},2:{count: 50,sku_attributes: {'颜色':'白','尺寸':'L'}}}
    for key,value of sku_list
      newSKU = new ProductInventory.Models.SKU(id: key, count: value['count'], sku_attributes: value['sku_attributes'])
      skuCollection.add(newSKU)

    hash = {'颜色':['红','白'],'尺寸':['L','XL']}
    for key,value of hash
      newPropertyValues = new ProductInventory.Collections.PropertyValues
      for v in value
        console.log "for v of value", v
        newValue = new ProductInventory.Models.PropertyValue(property_value: v)
        newPropertyValues.add(newValue)

      newProperty = new ProductInventory.Models.Property(name: key, property_values: newPropertyValues)
      propertyCollection.add(newProperty)
    propertyCollection


  render: ->


    # 读出（model生成模式）

    $('#product_inventory_options').html @template()
    @properties.each (propertyModel) ->
      propertyView = new ProductInventory.View.Property(model: propertyModel)
      $('#product_inventory_options .buy_now_option').append propertyView.render().el
      # console.log "$(@$el).find('.buy_now_option')", $(@$el).find('.buy_now_option').html()
      # $(@$el).find('.buy_now_option').append propertyView.render().el
      propertyModel.get('property_values').each (value) ->
        propertyValueModel = new ProductInventory.Models.PropertyValue(value: value.get('property_value' ))
        parentPorperty = $('#product_inventory_options').find("##{propertyModel.cid}")
        parentPorperty.find('ul').append new ProductInventory.View.PropertyValue(model: propertyValueModel).render().el
    @

  selectSkuItem: (e)->
    if $(e.target).parent('.sku').length == 1
      unSelectValues = $($(e.target).parents('ul')).find('.item_click')
      unSelectValues.removeClass('item_click')
      valueCid = unSelectValues.attr('id')
      console.log "valueCid", valueCid

      propertyCid = $($(e.target).parents('div')[0]).attr('id')
      console.log "propertyCid ", propertyCid

      console.log "propertyCollection.get(propertyCid)", @properties.get(propertyCid)
      $(e.target).parent('.sku').addClass('item_click')
