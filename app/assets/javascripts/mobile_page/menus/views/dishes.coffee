class Menus.Views.Dishes extends Backbone.View

  template: JST['mobile_page/menus/templates/dishes']

  el: '#dishes-order-box'

  events:
    "click .increase-dishe-amount": 'increase'
    "click .reduce-dishe-amount": 'reduce'
    'click .dishes-pop-bg .close-area': 'remove'
    'click #dishes-clear': 'clearDishes'

  increase: (e)->
    dishe = @getDishe(e)
    dishe.set("amount", dishe.get("amount") + 1)
    Dispatcher.trigger Menus.Events.DISHE_CHANGED, dishe

  reduce: (e)->
    dishe = @getDishe(e)
    amount = dishe.get("amount")
    if amount == 1
      window.dishes.remove dishe
      @render()
    else
      dishe.set("amount", amount - 1)
    @remove() if window.dishes.length is 0
    Dispatcher.trigger Menus.Events.DISHE_REMOVED, dishe

  getDishe: (e) ->
    disheId = $(e.target).parent().parent().data("dishe-id")
    window.dishes.findWhere({id: disheId})

  remove: (e)->
    $(@el).removeClass('show')

  clearDishes: ->
    window.dishes.each (dishe) ->
      window.dishes.remove dishe
      Dispatcher.trigger Menus.Events.DISHE_REMOVED, dishe
    @render({display: false})

  render: (options={}) ->
    @$el.html @template({dishes: window.dishes.models})
    if options.display == false
      $('#dishes-order-box').removeClass("show")
    else
      $('#dishes-order-box').addClass("show")
    new IScroll('#dishes-order-list',{click:iScrollClick()});
    @