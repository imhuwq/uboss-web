#= require underscore-min
#= require backbone-min
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views

((root) ->

  # disable backbone sync
  Backbone.sync = ->
    return false

  Category =
    TemplatesPath: 'admin/category_app/templates'
    Data: {}
    Views: {}
    Models: {}
    Collections: {}

  root.Category = Category

)(window)
jQuery ($) ->
  console.log 'category_app'
  category_main = new Category.Views.Main
  $('#category').innerHTML( category_main.render() )
