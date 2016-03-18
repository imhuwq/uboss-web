class StockSku.Views.StockItem extends Backbone.View

  tagName: 'tr'

  events:
    'blur input.sku-price': 'setPrice'
    'blur input.sku-cost-price': 'setCostPrice'
    'blur input.sku-suggest-price-lower': 'setPriceLower'
    'blur input.sku-suggest-price-upper': 'setPriceUpper'
    'blur input.sku-cost-price': 'setCostPrice'
    'blur input.sku-count': 'setCount'
    'change input.check-sale-to-agency': 'setSale'
    'change input.check-sale-out': 'setSaleout'

  initialize: (options)->
    @listenTo @model, "change:id", @render
    @listenTo @model, 'invalid', @showErrors
    @listenTo @model, "change:price", @clearPriceErrors
    @listenTo @model, "change:count", @clearCountErrors
    @listenTo @model, "change:share_amount_total", @clearPriceErrors
    @options = options
    @template = JST["#{StockSku.TemplatesPath}/stock_item/#{options.type}"]

  render: ->
    @$el.html @template(@model.toJSON())
    @

  clearPriceErrors: ->
    console.log 'clearPriceErrors'
    @$('input.sku-price').parent().find('span.error').remove()

  clearCountErrors: ->
    @$('input.sku-count').parent().find('span.error').remove()

  showErrors: (model, error)->
    if !!error.price and @$('input.sku-price').parent().find('.error').length == 0
      @$('input.sku-price').parent().append("<span class='error'>#{error.price}</span>")
    else
      @clearPriceErrors()
    if !!error.count and @$('input.sku-count').parent().find('.error').length == 0
      @$('input.sku-count').parent().append("<span class='error'>#{error.count}</span>")
    else
      @clearCountErrors()

  setPrice: (e)->
    price = Number($(e.target).val()).toFixed(2)
    cost_price = Number($(e.target).closest('tr').find('.sku-cost-price').val()).toFixed(2)
    result = @model.set 'price', Number(price), validate: true
    if not !!result
      @$('input.sku-price').val @model.get('price')
    else
      @$('input.sku-price').val price
      $(e.target).closest('tr').find('td.profit').html((price - cost_price).toFixed(2))

  setCostPrice: (e)->
    cost_price = Number($(e.target).val()).toFixed(2)
    result = @model.set 'cost_price', Number(cost_price), validate: true
    if not !!result
      @$('input.sku-cost-price').val @model.get('cost_price')
    else
      @$('input.sku-cost-price').val cost_price

  setPriceLower: (e)->
    suggest_price_lower = Number($(e.target).val()).toFixed(2)
    result = @model.set 'suggest_price_lower', Number(suggest_price_lower), validate: true
    if not !!result
      @$('input.sku-suggest-price-lower').val @model.get('suggest_price_lower')
    else
      @$('input.sku-suggest-price-lower').val suggest_price_lower

  setPriceUpper: (e)->
    suggest_price_upper = Number($(e.target).val()).toFixed(2)
    result = @model.set 'suggest_price_upper', Number(suggest_price_upper), validate: true
    if not !!result
      @$('input.sku-suggest-price-upper').val @model.get('suggest_price_upper')
    else
      @$('input.sku-suggest-price-upper').val suggest_price_upper

  setCount: (e)->
    count = parseInt(Number($(e.target).val()))
    result = @model.set 'count', count, validate: true
    if not !!result
      @$('input.sku-count').val @model.get('count')
    else
      @$('input.sku-count').val count
      if @model.collection?
        total = @model.collection.reduce (num, item)->
          Number(item.get('count')) + num
        , 0
        $('#product_count').val(total)
  setSale: (e)->
    $(e.target).closest('td').find(':hidden').val($(e.target).prop('checked'))
  setSaleout: (e)->
    $(e.target).closest('td').find(':hidden').val($(e.target).prop('checked'))
