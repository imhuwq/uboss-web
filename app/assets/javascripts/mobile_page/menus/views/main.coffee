class Menus.Views.Main extends Backbone.View

  el: '.container'

  events:
    'click .menus': 'showMenu'
    'click .add-to-dishes': 'increase'
    'click .remove-from-dishes': 'reduce'
    'click .dishes-add-btn': 'addToDishe'
    'click #order-buy-btn': 'submit'
    'click .dishes-order-price, .order-icon': 'showDishes'

  showMenu: (product) ->
    @product  = new Menus.Models.Product(product)
    @barView  = new Menus.Views.Bar({model: @product}).render()
    @skusView = new Menus.Views.Skus({collection: product.skus}).render()
    @skusView.parent = @barView

  showDishes: () ->
    if !@dishesView
      @dishesView = new Menus.Views.Dishes()
    @dishesView.render()

  increase: (e) ->
    that = this
    $.ajax
      url: '/products/' + @getProductId(e) + '/info'
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
    amount = dishe.get("amount")
    if amount == 1
      window.dishes.remove dishe
    else
      dishe.set "amount", amount - 1
    Dispatcher.trigger Menus.Events.DISHE_REMOVED, dishe

  getProductId: (e) ->
    element = e.currentTarget.parentElement.parentElement
    $(element).data("product-id")

  addToDishe: () ->
    skuIds = @skusView.stack.get("box")
    if skuIds.length == 0 || skuIds.length > 1
      alert('请选择规格')
      return
    skuId = parseInt(skuIds[0])
    sku = _.findWhere(@product.get("items"), { id: skuId })
    sku.product_id = @product.id
    sku.name  = @product.get("name")
    amount = @barView.model.get("count")
    if dishe = window.dishes.findWhere({ id: skuId })
      dishe.set "amount", amount + dishe.get("amount")
      Dispatcher.trigger Menus.Events.DISHE_CHANGED, dishe
    else
      dishe = new Menus.Models.Dishe(sku)
      dishe.set "amount", amount
      window.dishes.push dishe
      Dispatcher.trigger Menus.Events.ADDED_DISHE, dishe
    Dispatcher.trigger Menus.Events.DISPLAY_BAR, 'hide'

  submit: (e)->
    e.stopPropagation()
    order_items_attributes = []
    window.dishes.each (dishe) ->
      order_items_attributes.push({ amount: dishe.get("amount"), product_inventory_id: dishe.get("id") })
    $.ajax
      type: 'POST'
      url: window.location.pathname + '/confirm'
      data: { order_items_attributes: order_items_attributes }
      success: (req) ->
        console.log req
      