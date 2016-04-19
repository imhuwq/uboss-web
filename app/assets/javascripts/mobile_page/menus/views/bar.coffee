class Menus.Views.Bar extends Backbone.View

  template: JST['mobile_page/menus/templates/specbar']

  el: '#product-specs'

  events:
    'click .increase': 'increase'
    'click .reduce': 'reduce'
    'click .close-area': 'closeBar'

  closeBar: (e) ->
    Dispatcher.trigger Menus.Events.DISPLAY_BAR, 'hide'

  reduce: (e) ->
    count = @model.get("count")
    if count > 1
      @model.set("count", count - 1)

  increase: (e) ->
    count = @model.get("count")
    @model.set("count", count + 1)

  changeNum: ()->
    $("#spec-num").text(@get("count"))

  initialize: () ->
    @model.on "change", @changeNum

  render: ()->
    @$el.html @template(@model.attributes)
    @
