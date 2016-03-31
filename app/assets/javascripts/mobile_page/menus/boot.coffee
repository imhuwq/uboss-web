#= require underscore-min
#= require backbone-min
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views

console.log "menus is ready"

((root) ->
  # disable backbone sync

  Menus = 
    Views: {}
    Models: {}
    Collections: {}
    Events: {}
  root.Menus = Menus

  _.each [
    'SKU_SELECT_DONE'
    'CLOSE_BAR'
    'ADDED_DISHE'
    'DISHE_CHANGED'
    'DISHE_REMOVED'
    'DISPLAY_BAR'
  ], (e) ->
    Menus.Events[e] = e;

    root.Dispatcher = _.clone(Backbone.Events)

)(window)

Zepto ($) ->
  ((root) ->
    root.dishes = new Menus.Collections.Dishes
    root.menus  = new Menus.Views.Main

    Dispatcher.on Menus.Events.ADDED_DISHE, (dishe) ->
      productId = dishe.get("product_id")
      element = $("[data-product-id='" + productId + "']")
      element.find("div.num-box>.remove-from-dishes,div.num-box>.num").removeClass("disabled")
      amount = window.dishes.where({product_id: productId}).reduce (s, item) ->
        s + item.get("amount")
      , 0

      if amount > 0
        element.find("div.num-box>.num").text amount
      else
        element.find("div.num-box>.remove-from-dishes,div.num-box>.num").addClass("disabled")
      recalculateBar()
      $("[data-dishe-id='" + dishe.id + "'] .num").text(dishe.get("amount"))

    Dispatcher.on Menus.Events.DISHE_CHANGED, (dishe) ->
      Dispatcher.trigger Menus.Events.ADDED_DISHE, dishe

    Dispatcher.on Menus.Events.DISHE_REMOVED, (dishe) ->
      Dispatcher.trigger Menus.Events.ADDED_DISHE, dishe

    Dispatcher.on Menus.Events.SKU_SELECT_DONE, (action) ->
      switch action
        when 'disable' then $(".dishes-add-btn").addClass("disabled")
        when 'enable'  then $(".dishes-add-btn").removeClass("disabled")

    Dispatcher.on Menus.Events.DISPLAY_BAR, (action) ->
      switch action
        when 'show' then $(".dishes-pop-bg").addClass("show")
        when 'hide' then $(".dishes-pop-bg").removeClass("show")

    recalculateBar = ->
      recalculateBarNum()
      recalculateBarPrice()

    recalculateBarNum =  ->
      num = window.dishes.reduce (n, d) ->
        n + d.get('amount')
      ,0
      if num > 0
        $("#order-buy-btn").removeClass("disabled")
      else
        $("#order-buy-btn").addClass("disabled")
      $("#order-count").text(num)

    recalculateBarPrice = ->
      price = window.dishes.reduce (sum, dishe) ->
        sum + dishe.get('amount') * dishe.get("price")
      , 0
      $("#dishes-total-price").text(price)
  )(window)
