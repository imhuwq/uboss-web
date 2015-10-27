class ProductInventory.View.BuyNowOption extends Backbone.View

  template: JST["#{ProductInventory.TemplatesPath}/buy_now_option"]
  className: "buy_now_option"
  el: "#product_inventory_options"
  properties: null
  relate_sku_ids: []
  product_id: '1'
  pre_relate_sku_ids: {}
  submit_way: ''
  skus: null
  single_price: 0
  total_price: 0
  count: 1

  events:
    'click .sku': 'selectSkuItem'
    'click #confirm-inventory' : 'confirmInventory'
    'click .count_min' : 'minNum'
    'click .count_plus' : "plusNum"
    'change .count_num' : 'limitToNumChange'
    'keyup  .count_num' : 'limitToNumKeyup'
    'keypress .count_num' : 'limitToNumKeypress'

  getSKU: (product_inventory_ids=[])->

    that = this
    $.ajax
      url: '/products/get_sku'
      type: 'GET'
      data: {product_id: that.product_id}
      success: (res) ->
        # 获取属性列表 ->>
        that.newProperties(res['skus'])
        # <<= 获取属性列表
        # 获取sku信息 ->>
        that.newSKUs(res['sku_details'])
        # <<= 获取sku信息
        that.render('','',that.submit_way,that.product_id)
      error: (data, status, e) ->
        alert("ERROR")

  newProperties: (properties) ->
    that = this
    that.properties = new ProductInventory.Collections.Properties
    cid = ''
    for key,value of properties
      newPropertyValues = new ProductInventory.Collections.PropertyValues
      for k,v of value
        newValue = new ProductInventory.Models.PropertyValue(property_value: k, relate_sku: v, disabled: "false")
        newPropertyValues.add(newValue)

      newProperty = new ProductInventory.Models.Property(name: key, property_values: newPropertyValues)
      cid = newProperty.cid
      that.properties.add(newProperty)

  newSKUs: (skus) ->
    that = this
    that.skus = new ProductInventory.Collections.SKUs
    for key,value of skus
      newSKU = new ProductInventory.Models.SKU(id: key, count: value['count'], sku_attributes: value['sku_attributes'],price: value['price'])
      that.skus.add(newSKU)



  render: (product_inventory_ids = [], select_value_cid="", submit_way="",product_id='')-> # 读出（model生成模式）
    that = this
    hash = {a:[1,2,3],b:[4,5,6],c:[7,8,9]}
    for k,v of hash
      console.log "#{k}=", v

    @submit_way = submit_way
    @product_id = product_id

    if @skus == null || @properties == null
      @getSKU()
      return

    @$el.html @template(count: @count)
    @judgeItemDisable(product_inventory_ids, select_value_cid)
    @judgeItemClick()
    @

  judgeItemClick: () ->
    that = this
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



  judgeItemDisable: (product_inventory_ids = [], select_value_cid="") ->

    that = this
    @properties.each (propertyModel) ->
      propertyModel.get('property_values').each (value) ->
        if select_value_cid.length > 0 && select_value_cid == value.cid
          that.pre_relate_sku_ids[propertyModel.cid] = product_inventory_ids

    @properties.each (propertyModel) ->
      propertyView = new ProductInventory.View.Property(model: propertyModel)
      $('#product_inventory_options .buy_now_option').append propertyView.render().el
      # 找出已选属性值的同级所有属性值的cid
      property_model_value_cids = []
      propertyModel.get('property_values').each (value) ->
        if select_value_cid.length > 0 && select_value_cid == value.cid
          propertyModel.get('property_values').each (value) ->
            property_model_value_cids = property_model_value_cids.concat([value.cid])

      propertyModel.get('property_values').each (value) ->
        parentPorperty = $('#product_inventory_options').find("##{propertyModel.cid}")
        if product_inventory_ids.length > 0 && value.attributes.relate_sku.intersect(product_inventory_ids).length == 0 && property_model_value_cids.intersect([value.cid]).length == 0
          value.attributes.disabled = "true"
        else
          init = []
          for k,v of that.pre_relate_sku_ids
            if k != propertyModel.cid
              if init.length == 0
                init = v
              else
                init = init.intersect(v)
          if product_inventory_ids.length > 0 && value.attributes.relate_sku.intersect(init).length > 0
            value.attributes.disabled = "false"

        if select_value_cid.length > 0 && select_value_cid == value.cid
          value.attributes.selected = "true"
        else if property_model_value_cids.intersect([value.cid]).length > 0 || value.attributes.disabled == "true"
          value.attributes.selected = "false"
        parentPorperty.find('ul').append new ProductInventory.View.PropertyValue(model: value).render().el

  selectSkuItem: (e) ->
    if $(e.target).parent('.sku').length == 1
      unSelectValues = $($(e.target).parents('ul')).find('.item_click')
      unSelectValues.removeClass('item_click') # 取消原来同级选中状态
      valueCid = $(e.target).parents('.sku').attr('id') # 获取属性cid
      propertyCid = $($(e.target).parents('div')[0]).attr('id') # 获取属性值cid
      relate_sku_ids = @properties.get(propertyCid).attributes.property_values.get(valueCid).attributes.relate_sku # 获取关联sku的ids
      if @relate_sku_ids.length == 1
        # @single_price = @skus.search(@relate_sku_ids[0],['id']).at(0).attributes.price
        console.log "@relate_sku_ids[0]", @relate_sku_ids[0]
        console.log "@skus.where({'id':@relate_sku_ids[0]})", @skus.where('id': "#{@relate_sku_ids[0]}")
        console.log "@skus", @skus
        @single_price =  @skus.where('id': "#{@relate_sku_ids[0]}")[0].attributes.price
        @calculateTotalPrice()
      @render(relate_sku_ids,valueCid,@submit_way)

  confirmInventory: (e) ->
    e.preventDefault()
    if @relate_sku_ids.length == 1
      $('#product_inventory_id').val(@relate_sku_ids[0])
      count = Number($('.count_num').val())
      if count >= 1
        if @submit_way == 'buy'
          $('.product_inventory').submit()
        else if @submit_way == 'cart'
          product_inventory_id = Number(@relate_sku_ids[0])
          product_id = Number(@product_id)
          $.ajax
            url: '/cart_items'
            type: 'POST'
            data: {product_inventory_id: product_inventory_id, product_id: product_id, count: count}
            success: (res) ->
              if res['status'] == "ok"
                alert('添加成功，购物车有'+res['cart_items_count']+'件商品')
              else
                location.reload()
                alert(res['message'])
            error: (data, status, e) ->
              alert("ERROR")
      else
        alert "请填写正确的商品数量"
    else
      alert "请选择您需要购买的属性。"

  checkInventoriesSelect = ->
    product_inventory_id = $('#product_inventory_id').val();
    if product_inventory_id == ''
      alert "请勾选您要的商品信息！"
      return false
    else
      return true




  Array.prototype.intersect = (b) ->
    flip = {};
    res = [];
    for _b,i in b
      flip[b[i]] = i
    for _this,i in this
      if flip[this[i]] != undefined
        res.push(this[i])
    return res;

  minNum: ->
    num=parseInt($('.count-box .count_num').val())
    if num < 2
      alert('数量必须大于1')
      $('.count-box .count_num').val(1)
      $('#count_amount').val(1)
    else
      $('.count-box .count_num').val(num-1)
      $('#count_amount').val(num-1)
      @count = num-1
      @calculateTotalPrice()


  plusNum: ->
    num=parseInt($('.count-box .count_num').val())
    $('.count-box .count_num').val(num+1)
    $('#count_amount').val(num+1)
    @count = num+1
    @calculateTotalPrice()


  limitToNumKeyup: ->
      $this = $(this)
      this.value = this.value.replace(/[^\d]/g, '')

  # 限制只能输入数字
  limitToNumKeypress: (event) ->
    eventObj = event || e
    keyCode = eventObj.keyCode || eventObj.which
    if (keyCode >= 48 && keyCode <= 57)
      return true
    else
      return false
    this.focus () ->
      this.style.imeMode = 'disabled' # 禁用输入法
    this.bind "paste", () ->              # 禁用粘贴
      return false

  limitToNumChange: ->
    $this = $(this)
    this.value = this.value.replace(/[^\d]/g, '')
    $('#count_amount').val(this.value)
    if this.value == '' || this.value == "0"
      this.value = 1
      $('#count_amount').val(1)

  calculateTotalPrice: ->
    @total_price = @single_price * @count
    if @relate_sku_ids.length == 1
      product_inventory_property_price_range.render(@total_price)
