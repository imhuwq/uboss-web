class ProductInventory.View.BuyNowOption extends Backbone.View

  template: JST["#{ProductInventory.TemplatesPath}/buy_now_option"]

  className: "buy_now_option"

  el: "#product_inventory_options"

  properties: null

  total_property_values: null

  relate_sku_ids: []

  pre_relate_sku_ids: []

  # skus: null

  # initialize: ->
  #   @getSKU()

  events:
    'click .sku': 'selectSkuItem'
    'click #make_order' : 'makeOrder'


  # getSKU: (product_id)->
  #   # 获取sku信息 ->>
  #   @skus = new ProductInventory.Collections.SKUs
  #   sku_list = { '1': {count: 100, sku_attributes: {'颜色': '红', '尺寸': 'XL'}}, '2': {count: 50, sku_attributes: {'颜色': '白', '尺寸': 'L'}} }
  #   for key,value of sku_list
  #     newSKU = new ProductInventory.Models.SKU(id: key, count: value['count'], sku_attributes: value['sku_attributes'])
  #     @skus.add(newSKU)
  #   # <<= 获取sku信息


  getProperties: (product_inventory_ids=[])-> # 写入（model生成模式）

    # 获取属性列表 ->>
    @properties = new ProductInventory.Collections.Properties
    @total_property_values = new ProductInventory.Collections.PropertyValues
    hash = {'颜色':{'红': [1,2],'白': [3,4],'黄': [3]},'尺寸':{'L':[1,3],'XL':[2,4]}}

    for key,value of hash
      newPropertyValues = new ProductInventory.Collections.PropertyValues
      for k,v of value
        if product_inventory_ids.length > 0 && v.intersect(product_inventory_ids).length == 0
          newValue = new ProductInventory.Models.PropertyValue(property_value: k, relate_sku: v, disabled: "true")
          newPropertyValues.add(newValue)
        else
          newValue = new ProductInventory.Models.PropertyValue(property_value: k, relate_sku: v, disabled: "false")
          newPropertyValues.add(newValue)

      newProperty = new ProductInventory.Models.Property(name: key, property_values: newPropertyValues)
      @properties.add(newProperty)

    # <<= 获取属性列表


  render: (product_inventory_ids = [], select_value_cid="")-> # 读出（model生成模式）

    that = this

    if @properties == null
      @getProperties()

    $('#product_inventory_options').html @template()
    @properties.each (propertyModel) ->
      propertyView = new ProductInventory.View.Property(model: propertyModel)
      $('#product_inventory_options .buy_now_option').append propertyView.render().el

      # 找出已选属性值的同级所有属性值的cid
      property_model_value_cids = []
      propertyModel.get('property_values').each (value) ->
        if select_value_cid.length > 0 && select_value_cid == value.cid
          # propertyModel.attributes.selected_sku_ids = value.relate_sku
          propertyModel.get('property_values').each (value) ->
            property_model_value_cids = property_model_value_cids.concat([value.cid])


      propertyModel.get('property_values').each (value) ->
        parentPorperty = $('#product_inventory_options').find("##{propertyModel.cid}")
        if product_inventory_ids.length > 0 && value.attributes.relate_sku.intersect(product_inventory_ids).length == 0 && property_model_value_cids.intersect([value.cid]).length == 0
          value.attributes.disabled = "true"
        else if product_inventory_ids.length > 0 && value.attributes.relate_sku.intersect(product_inventory_ids).length > 0
          value.attributes.disabled = "false"

        if select_value_cid.length > 0 && select_value_cid == value.cid
          value.attributes.selected = "true"
        else if property_model_value_cids.intersect([value.cid]).length > 0 || value.attributes.disabled == "true"
          value.attributes.selected = "false"

        parentPorperty.find('ul').append new ProductInventory.View.PropertyValue(model: value).render().el

    # if that.relate_sku_ids.length == 0
    #   that.relate_sku_ids = product_inventory_ids
    # else if that.relate_sku_ids.length > 1
    #   that.relate_sku_ids = that.relate_sku_ids.intersect(product_inventory_ids)
    # else if that.relate_sku_ids.length == 1
    #   that.relate_sku_ids = that.pre_relate_sku_ids.intersect(product_inventory_ids)

    # that.pre_relate_sku_ids[select_value_cid] = product_inventory_ids
    # for key,value,i for that.pre_relate_sku_ids
    #   if i==0
    #     that.relate_sku_ids = value
    #   else
    #     that.relate_sku_ids = that.relate_sku_ids.intersect(value)
    #
    # console.log "@relate_sku_ids", that.relate_sku_ids
    #
    # @properties.each (propertyModel) ->
    #   propertyModel.selected_sku_ids
    cids = []
    that.relate_sku_ids = []
    for tag in $('.item_click')
      cids = cids.concat( $(tag).attr('id'))

    @properties.each (propertyModel) ->
      propertyModel.get('property_values').each (value) ->
        if cids.intersect([value.cid]).length > 0
          if that.relate_sku_ids.length == 0
            that.relate_sku_ids = value.attributes.relate_sku
          else
            that.relate_sku_ids = that.relate_sku_ids.intersect( value.attributes.relate_sku )
    @

  selectSkuItem: (e) ->
    if $(e.target).parent('.sku').length == 1
      unSelectValues = $($(e.target).parents('ul')).find('.item_click')
      unSelectValues.removeClass('item_click') # 取消原来同级选中状态
      valueCid = $(e.target).parents('.sku').attr('id') # 获取属性cid
      propertyCid = $($(e.target).parents('div')[0]).attr('id') # 获取属性值cid
      relate_sku_ids = @properties.get(propertyCid).attributes.property_values.get(valueCid).attributes.relate_sku # 获取关联sku的ids

      @render(relate_sku_ids,valueCid)

  makeOrder: (e) ->
    console.log "@relate_sku_ids", @relate_sku_ids
    if @relate_sku_ids.length == 1
      $('#product_inventory_id').val(@relate_sku_ids[0])
      want_buy = confirm "确认购买么？"
      if want_buy
          $('.product_inventory').submit()
    else
      confirm "请选择您需要购买的属性。"




  Array.prototype.intersect = (b) ->
    flip = {};
    res = [];
    for _b,i in b
      flip[b[i]] = i

    for _this,i in this
      if flip[this[i]] != undefined
        res.push(this[i])
    return res;
