class ProductInventory.View.PropertyValue extends Backbone.View

  template: JST["#{ProductInventory.TemplatesPath}/property_value"]
  tagName: 'li'
  className: "item sku"

  render: ->
    @$el.html @template(property_value: @model.attributes.value)
    $(@$el).attr('id', @model.cid)
    @
