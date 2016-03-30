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
  root.Menus = Menus

)(window)

Zepto ($) ->
  ((root) ->
    root.dishes = new Menus.Collections.Dishes
    root.menus  = new Menus.Views.Main
  )(window)
