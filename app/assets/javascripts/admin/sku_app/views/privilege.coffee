class StockSku.Views.Privilege extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/privilege"]

  el: '#sku-privelege-group'

  events:
    'click .sku-plvs-btns .btn': 'setLevel'

  initialize: ->
    @listenTo @collection, 'skuchange', @render
    @listenTo @, 'initShow', @render
    @currentLevel = @$('.sku-plvs-btns .btn').eq(0).data('level')
    if @currentLevel == undefined
      @currentLevel = 1
    @setLevel()

  propertyCollection: ->
    StockSku.Collections.property_collection

  render: ->
    skuCollection = @propertyCollection()
    return @ unless skuCollection?

    skuCollection = skuCollection.available()
    propertys = skuCollection.map (item)-> item.get('name')
    @$('.sku-privilege-list').html @template(propertys: propertys)

    @clearPrivilegeItemViews()
    @privilegeItemViews = []
    @propertyCollection().renderStockItems(@renderPrivilegeView.bind(@))
    @

  renderPrivilegeView: (skuAttrs) ->
    stockIdentify = JSON.stringify(skuAttrs)
    stockItemModel = @collection.findWhere(identify: stockIdentify)
    unless stockItemModel?
      stockItemModel = @collection.add(id: skuPVId + stockIndex, sku_attributes: skuAttrs)
    stockItemView = new StockSku.Views.PrivilegeItem(model: stockItemModel)
    @privilegeItemViews.push(stockItemView)
    @$('table#privilege-list-table tbody').append stockItemView.render().el
    @

  setLevel: (event)->
    if event?
      event.preventDefault()
      @currentLevel = Number($(event.currentTarget).data('level'))
      @collection.each (privilegeItem) =>
        privilegeItem.set('share_level', @currentLevel)
        privilegeItem.calculateSharingAmount()
    @$('.sku-plvs-btns .btn').each (_, btn) =>
      btn = $(btn)
      if btn.data('level') == @currentLevel
        btn.removeClass('btn-link')
      else
        btn.addClass('btn-link')
    @

  clearPrivilegeItemViews: ->
    _.each @privilegeItemViews, (view) -> view.remove()
