class StockSku.Models.Stock extends Backbone.Model

  idAttribute: 'identify'

  initialize: ->
    @set('identify', JSON.stringify(@get('sku_attributes')))
    @listenTo @, 'change:share_amount_total', @calculateSharingAmount
    @listenTo @, 'change:share_level', @calculateSharingAmount

  defaults:
    sku_attributes: {}
    count: 0
    price: 0
    cost_price: 0
    suggest_price_lower: 0
    suggest_price_upper: 0
    sale_to_agency: true
    quantity: 0
    share_amount_total: 0
    share_amount_lv_1: 0
    share_amount_lv_2: 0
    share_amount_lv_3: 0
    share_level: 1
    privilege_amount: 0

  validate: (attrs, options) ->
    console.log 'attrs', attrs
    errors = {}
    suggest_price_lower = Number(@get('suggest_price_lower'))
    suggest_price_upper = Number(@get('suggest_price_upper'))
    isSupplierProduct = App.controller == "admin/supplier_products" ? true : false
    if attrs.count < 0
      errors.count = '库存必须大于0'
    if !isSupplierProduct && attrs.share_amount_total >= attrs.price
      errors.share_amount_total = '返利需小于商品价格'
      errors.price = '商品价格需大于返利值'
    if attrs.share_amount_total < 0
      errors.share_amount_total = '返利不能小于0'
    if !isSupplierProduct && attrs.price < 0.01
      errors.price = '价格必须大于0.01'
    if !isSupplierProduct && suggest_price_lower + suggest_price_upper > 0
      if attrs.price < suggest_price_lower
        errors.price = '价格必须大于等于' + suggest_price_lower
      if suggest_price_upper && attrs.price > suggest_price_upper
        errors.price = '价格必须小于等于' + suggest_price_upper
    if not _.isEmpty(errors)
      return errors

  sharingRate:
    'level1': [80, 0,  0]
    'level2': [50, 40, 0]
    'level3': [40, 30, 20]

  calculateSharingAmount: ->
    shareAmountTotal = Number(@get('share_amount_total'))
    assignedTotal = 0

    _(3).times (level) =>
      amount = (parseInt(shareAmountTotal * @getSharingRate(level))/100).toFixed(2)
      @attributes["share_amount_lv_#{level+1}"] = amount
      assignedTotal += Number(amount)
    @attributes['privilege_amount'] = (shareAmountTotal - assignedTotal).toFixed(2)
    @trigger('sharingAmountChanged')

  getSharingRate: (rateLevel) ->
    @sharingRate["level#{@get('share_level')}"][rateLevel]
