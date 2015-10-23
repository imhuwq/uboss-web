class StockSku.Views.Privilege extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/privilege"]

  el: '#sku-privelege-group'

  events:
    'click .sku-plvs-btns .btn': 'setLevel'

  initialize: ->
    @listenTo @collection, 'skuchange', @render
    @listenTo @, 'initShow', @render
    @currentLevel = 3
    @setLevel()

  render: ->
    skuCollection = StockSku.Collections.property_collection
    return @ unless skuCollection?

    skuCollection = skuCollection.available()
    propertys = skuCollection.map (item)-> item.get('name')
    @.$('.sku-privilege-list').html @template(propertys: propertys)

    return @ unless skuCollection.length > 0
    property_counter = skuCollection.map (item)-> item.get('values').length
    property_group_counter = []
    _.each property_counter, (__, pcIndex) ->
      groupTotal = 1
      _.each property_counter.slice(pcIndex+1, property_counter.length), (totalPv)->
        groupTotal *= totalPv
      property_group_counter.push(groupTotal)

    @renderPrivilegeItem(skuCollection, property_group_counter)
    @

  renderPrivilegeItem: (skuCollection, property_group_counter, skuIndex = 0, skuAttrs = {})->
    property = skuCollection[skuIndex]
    propertyValues = property.get('values')
    propertyType = property.get('name')
    propertyValues.each (propertyValue) =>
      skuAttrs[propertyType] = propertyValue.get('value')
      groupTotal = property_group_counter[skuIndex]
      if groupTotal == 1
        @getPrivilegeView(skuAttrs)
      else
        @renderPrivilegeItem(skuCollection, property_group_counter, skuIndex+1, skuAttrs)
    @

  getPrivilegeView: (skuAttrs) ->
    stockIdentify = JSON.stringify(skuAttrs)
    stockItemModel = @collection.findWhere(identify: stockIdentify)
    unless stockItemModel?
      stockItemModel = @collection.add(id: skuPVId + stockIndex, sku_attributes: skuAttrs)
    stockItemView = new StockSku.Views.PrivilegeItem(model: stockItemModel)
    @.$('table#privilege-list-table tbody').append stockItemView.render().el
    @

  setLevel: (event)->
    if event?
      event.preventDefault()
      @currentLevel = Number($(event.currentTarget).data('level'))
      @collection.each (privilegeItem) =>
        privilegeItem.set('share_level', @currentLevel)
    @.$('.sku-plvs-btns .btn').each (_, btn) =>
      btn = $(btn)
      if btn.data('level') == @currentLevel
        btn.removeClass('btn-link')
      else
        btn.addClass('btn-link')
    @
