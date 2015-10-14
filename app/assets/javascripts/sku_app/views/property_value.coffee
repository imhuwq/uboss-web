class StockSku.Views.PropertyValue extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/property_value"]

  events:
    'click .remove-pv': 'removeValue'

  initialize: ->
    @listenTo @model, 'destroy', @removeViewAndRegenerarteSku

  render: ->
    @$el.html @template(value: @model.get('value'))
    @

  removeViewAndRegenerarteSku: ->
    console.log 'removeViewAndRegenerarteSku'
    @remove()

  removeValue: (e)->
    e.preventDefault()
    @model.destroy()
