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
    @barView  = new Menus.Views.Bar({model: @product}).render()
    @skusView = new Menus.Views.Skus({collection: product.skus, parent: @barView}).render(product.selected)

  showDishes: () ->
    if !@dishesView
      @dishesView = new Menus.Views.Dishes()
    @dishesView.render()

  increase: (e) ->
    that = this
    $.ajax
      url: '/products/' + @getProductId(e) + '/info'
      dataType: 'json'
      cache: true
      success: (result) ->
        that.product  = new Menus.Models.Product(result)
        count = result.items.length
        if count > 1
          that.showMenu(result)
        else if count is 0
          alert('菜品已售完')
        else if count is 1
          sku = result.items[0]
          that.addOrUpdateDishe(sku.id)

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
    @addOrUpdateDishe(skuId)
    Dispatcher.trigger Menus.Events.DISPLAY_BAR, 'hide'

  addOrUpdateDishe: (skuId) ->
    sku = _.clone _.findWhere(@product.get("items"), { id: skuId })
    sku.product_id = @product.id
    sku.name       = @product.get("name")
    amount         = @product.get("count")

    if dishe = window.dishes.findWhere({ id: skuId })
      dishe.set "amount", amount + dishe.get("amount")
      Dispatcher.trigger Menus.Events.DISHE_CHANGED, dishe
    else
      dishe = new Menus.Models.Dishe(sku)
      dishe.set "amount", amount
      window.dishes.push dishe
      Dispatcher.trigger Menus.Events.ADDED_DISHE, dishe

  submit: (e)->
    e.stopPropagation()
    Dispatcher.trigger Menus.Events.SUBMIT_DISHES, 'confirm'