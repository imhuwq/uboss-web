class Menus.Views.Dishes extends Backbone.View
  className: 'dishes-list'

  events:
    "click .plus": 'increase'
    "click .minus": 'reduce'

  increase: ->
    # ...
  reduce: ->
    # ...