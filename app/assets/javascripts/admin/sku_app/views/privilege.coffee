class StockSku.Views.Privilege extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/privilege"]

  el: '#sku-privelege-group'

  events:
    'click .sku-plvs-btns .btn': 'setLevel'

  initialize: ->
    @listenTo @collection, 'skuchange', @render
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

    console.log property_group_counter
    @renderPrivilegeItem(skuCollection, property_group_counter)
    @

  renderPrivilegeItem: (skuCollection, property_group_counter, skuIndex = 0) ->
    console.log("skuIndex:#{skuIndex}")
    propertyValues = skuCollection[skuIndex].get('values')
    propertyValues.each (propertyValue, pvIndex) =>
      groupTotal = property_group_counter[skuIndex]
      console.log("getTotal: #{groupTotal}")
      if groupTotal == 1
        @getPrivilegeView(skuIndex)
      else
        console.log "Recall: #{property_group_counter[skuIndex]}"
        @renderPrivilegeItem(skuCollection, property_group_counter, skuIndex+1)
        true

  getPrivilegeView: (attr) ->
    console.log("getPrivilegeView: #{attr}")
    false

  setLevel: (event)->
    console.log 'click lev'
    if event?
      event.preventDefault()
      @currentLevel = $(event.currentTarget).data('level')
    @.$('.sku-plvs-btns .btn').each (_, btn) =>
      btn = $(btn)
      if btn.data('level') == @currentLevel
        btn.removeClass('btn-link')
      else
        btn.addClass('btn-link')
    @
