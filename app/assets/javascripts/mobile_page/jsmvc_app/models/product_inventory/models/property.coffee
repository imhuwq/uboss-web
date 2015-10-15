class ProdectInventory.Models.Property extends Backbone.Model
  
  defaults:
    name: ""


  template: JST["#{ProductInventory.TemplatesPath}/property"]

  events:

  initialize: ->


  render: ->
    @$el.html @template(name: @model.get('name'))
    @
