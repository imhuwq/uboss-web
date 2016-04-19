class Menus.Models.Stack extends Backbone.Model
  # defaults:
  #   box: []
  #   elements: {}

  constructor: () ->
    @context = {}
    Backbone.Model.apply(this, arguments);