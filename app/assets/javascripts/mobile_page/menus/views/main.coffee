class Menus.Views.Main extends Backbone.View

  el: '.container'

  events:
    'click .menus': 'showMenu'
    'click .add-to-dishes': 'plus'
    'click .remove-from-dishes': 'reduce'
    'click .dishes-add-btn': 'addToDishe'
    'click #order-buy-btn': 'submit'

  initialize: ->
    @listenTo window.dishes, 'change add', @recalculateNum

  showMenu: (product) ->
    @product  = new Menus.Models.Product(product)
    @barView  = new Menus.Views.Bar({model: @product}).render()
    @skusView = new Menus.Views.Skus({collection: product.skus}).render()
    @skusView.parent = @barView
    console.log @skusView

  plus: (e) ->
    productId = @getProductId(e)
    that = this
    $.ajax
      url: '/products/' + productId + '/info'
      dataType: 'json'
      success: (result) ->
        if result.items.length > 1
          that.showMenu(result)
        else
          dishe = new Menus.Models.Dishe(result.items[0])
          dishe.set("count", 1)
          window.dishes.push(dishe)

  reduce: (e) ->
    productId = @getProductId(e)
    dishe = window.dishes.findWhere({product_id: productId})
    window.dishes.remove dishe

  getProductId: (e) ->
    element = e.currentTarget.parentElement.parentElement
    $(element).data("product-id")

  recalculateNum:  ->
    num = 0
    _.each window.dishes.models,  (dishe) -> num += dishe.get('amount')
    if num > 0
      $("#order-buy-btn").removeClass("disabled")
    else
      $("#order-buy-btn").addClass("disabled")

  addToDishe: () ->
    skuIds = @skusView.stack.get("box")
    if skuIds.length == 0 || skuIds.length > 1
      alert('请选择规格')
      return
    skuId = parseInt(skuIds[0])
    dishe = _.findWhere(@product.get("items"), { id: skuId })
    amount = @barView.model.get("count")
    if _dishe = window.dishes.findWhere({ id: skuId })
      _dishe.set "amount", amount + _dishe.get("amount")
    else
      dishe = _.clone dishe
      dishe.amount = amount
      window.dishes.add new Menus.Models.Dishe(dishe)

  submit: ->
    order_items_attributes = []
    _.each window.dishes.models, (dishe) ->
      order_items_attributes.push({ amount: dishe.get("amount"), product_inventory_id: dishe.get("id") })
    $.ajax
      type: 'POST'
      url: window.location.pathname + '/confirm'
      data: { order_items_attributes: order_items_attributes }
      success: (req) ->
        console.log req
      