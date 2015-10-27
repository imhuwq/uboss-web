class ProductInventory.View.Property extends Backbone.View

  template: JST["#{ProductInventory.TemplatesPath}/property"]

  render: ->
    @$el.html @template(property_name: @model.attributes.name, property_views: @model.property_views)
    $(@$el).attr('id', @model.cid)
    @
