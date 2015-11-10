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

  UserAddress =
    TemplatesPath: 'admin/user_address_app/templates'
    Data: {}
    Views: {}
    Models: {}
    Collections: {}

  root.UserAddress = UserAddress

)(window)
console.log 'main is  load'



jQuery ($) ->
  ((root) ->
    root.userAddressUsage = new UserAddress.Views.Usage
  )(window)
  $('#user_address_usage').html = userAddressUsage.render()
