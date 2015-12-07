#= require ./application

Zepto ($) ->

  UXin.init()
  window.router = new UXin.Router
  Backbone.history.start()
