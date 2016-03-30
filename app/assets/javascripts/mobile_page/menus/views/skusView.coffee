class Menus.Views.Skus extends Backbone.View
  template: JST['mobile_page/menus/templates/skus']

  el: ".dishes-sku-info"

  events:
    'click .sku-select span': 'selectSpec'

  initialize: (attributes) ->
    @stack = new Menus.Models.Stack({box: [], elements: {}})
    @stack.context = this
    @stack.on "change:elements", @calculateAndDisplay
    @stack.on "change:box", @calculatePrice

  selectSpec: (e)->
    elements = @stack.get("elements")
    target = $(e.target)
    text = target.parent().data("category")
    element = elements[text]
    if element && element.text() == target.text()
      delete elements[text]
    else
      elements[text] = target
    target.toggleClass('active')
    @stack.trigger 'change:elements'

  calculateAndDisplay: ()->
    that = this
    _.each @get("elements"), (element) ->
      children = $(element).parent().children()
      _.each children, (node) ->
        that.context.autoActiveSelected(node, element)
    @.set "box", that.context.autoDisabledSelect()

  calculatePrice: () ->
    product = @context.parent.model
    box = @get("box")
    if box.length == 1
      sku = _.findWhere(product.get("items"), {id: parseInt(box[0])})
      $("#dishes-price").text(sku.price)
      Dispatcher.trigger Menus.Events.SKU_SELECT_DONE, 'enable'
      console.log box
    else
      Dispatcher.trigger Menus.Events.SKU_SELECT_DONE, 'disable'
      console.log box

  autoActiveSelected: (a,b) ->
    if $(a).text() == b.text()
      $(a).addClass('active')
    else
      $(a).removeClass('active')

  autoDisabledSelect: () ->
    elements = @stack.get("elements")
    theSameIds = []
    skusElements = []
    _.each elements, (element) ->
      _.union(skusElements, element.parent().children())
      sid = element.attr('sid').split(':')
      sid.shift()
      theSameIds = if theSameIds.length == 0 then sid else _.intersection(theSameIds,sid)
    _.each skusElements, (element) ->
      sid = element.attr('sid').split(':')
      if _.intersection(sid, theSameIds).length < 1
        # disable sku
        console.log 0
      else
        # enable sku
        console.log 1
    theSameIds

  render: () ->
    console.log 'rendered skus'
    @$el.html @template({skus: @collection})
    $('#product-specs').addClass('show')
    $('html,body').on 'touchmove', (e) -> e.preventDefault();
    @