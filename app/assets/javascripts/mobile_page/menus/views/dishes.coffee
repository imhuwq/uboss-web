class Menus.Views.Dishes extends Backbone.View

  template: JST['mobile_page/menus/templates/dishes']

  el: '#dishes-order-box'

  events:
    "click .increase-dishe-amount": 'increase'
    "click .reduce-dishe-amount": 'reduce'
    'click .dishes-pop-bg .close-area': 'remove'
    'click #dishes-clear': 'clearDishes'

  increase: (e)->
    disheId = $(e.target).parent().data("disheId")
    dishe = window.dishes.findWhere({id: disheId})
    dishe.set("amount", dishe.get("amount") + 1)
  reduce: (e)->
    disheId = $(e.target).parent().data("dishe-id")
    dishe = window.dishes.findWhere({id: disheId})
    dishe.set("amount", dishe.get("amount") - 1)
  remove: (e)->
    $(e.target).closest('.dishes-pop-bg').removeClass('show');

  clearDishes: ->
    window.dishes.reset()

  render: () ->
    @$el.html @template({dishes: window.dishes.models})
    $('#dishes-order-box').addClass("show")
    new IScroll('#dishes-order-list',{click:iScrollClick()});
    @