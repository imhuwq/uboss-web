class ProductInventory.View.PropertyValue extends Backbone.View

  template: JST["#{ProductInventory.TemplatesPath}/property_value"]
  tagName: 'li'
  className: "item sku"

  render: ->
    if location.pathname.match('service_products')
      $('.buy_now_option').css('display', 'none')
    @$el.html @template(property_value: @model.attributes.property_value)
    $(@$el).attr('id', @model.cid)
    if @model.attributes.disabled == "true"
      $(@$el).addClass('disabled')
    if @model.attributes.selected == "true"
      $(@$el).addClass('item_click')
    @
