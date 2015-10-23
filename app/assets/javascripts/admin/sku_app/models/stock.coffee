class StockSku.Models.Stock extends Backbone.Model

  idAttribute: 'identify'

  sharingRate:
    'level1': [80, 0,  0]
    'level2': [50, 40, 0]
    'level3': [40, 30, 20]

  initialize: ->
    @set('identify', JSON.stringify(@get('sku_attributes')))
    @listenTo @, 'change:share_amount_total', @calculateSharingAmount
    @listenTo @, 'change:share_level', @calculateSharingAmount

  defaults:
    sku_attributes: {}
    count: 0
    price: 0
    share_amount_total: 0
    share_amount_lv_1: 0
    share_amount_lv_2: 0
    share_amount_lv_3: 0
    share_level: 3
    privilege_amount: 0

  calculateSharingAmount: ->
    shareAmountTotal = Number(@.get('share_amount_total'))
    assignedTotal = 0

    _(3).times (level) =>
      amount = (parseInt(shareAmountTotal * @getSharingRate(level))/100).toFixed(2)
      @.attributes["share_amount_lv_#{level+1}"] = amount
      assignedTotal += Number(amount)
    @.attributes['privilege_amount'] = (shareAmountTotal - assignedTotal).toFixed(2)
    @.trigger('sharingAmountChanged')

  getSharingRate: (rateLevel) ->
    @sharingRate["level#{@.get('share_level')}"][rateLevel]
