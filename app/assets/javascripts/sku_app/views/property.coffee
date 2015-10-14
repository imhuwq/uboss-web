class StockSku.Views.Property extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/sku_property"]

  tagName: 'div'

  events:
    'click a.remove-property': 'clear'
    'click a.add-pv': 'newPropertyValue'
    'click .show-sel-group': 'showPVSel'
    'click .cancel-sel': 'hidePVSel'

  initialize: ->
    @propertyValues = @model.get('values')
    window.pvs = @propertyValues
    @listenTo @model, 'change:name', @newProperty
    @listenTo @model, 'destroy', @removeProperty
    @listenTo @propertyValues, 'add', @addPropertyValue
    @setSelPVs()

  render: =>
    @$el.html @template(property: @model)
    @initSelect()
    @

  showPVSel: (e)->
    e.preventDefault()
    if !!@model.get('name')
      @.$('.pv-sel-group').show()
    else
      alert('请选择一个规格')

  hidePVSel: (e)->
    e? && e.preventDefault()
    @.$('.pv-sel-group').hide()

  newProperty: (e)->
    _.each @propertyValues.models, =>
      @propertyValues.models[0].destroy()
    @setSelPVs()
    @pvSelect2.select2('val', '')

  setSelPVs: ->
    pIndex = _.findLastIndex(StockSku.Data.propertyData, { name: @model.get('name') })
    @selectablePVs = if pIndex != -1
      StockSku.Data.propertyData[pIndex].product_property_values
    else
      []

  removeProperty: (e)->
    console.log 'removeProperty'
    @remove()

  addAllPropertyValue: ->
    @model.get('values').each (propertyValueItem)=>
      @addPropertyValue(propertyValueItem)

  addPropertyValue: (propertyValue)->
    console.log('addPropertyValue')
    pValueView = new StockSku.Views.PropertyValue(model: propertyValue)
    @.$('.pv-list').append pValueView.render().el
    @hidePVSel()

  newPropertyValue: (e)->
    e.preventDefault()
    if @pvSelect2.select2('data').length > 0
      console.log('newPropertyValue')
      @propertyValues.add(@pvSelect2.select2('data'))
      StockSku.stock_view.trigger('skuchange')
      @pvSelect2.select2('val', '')

  initSelect: ->
    @pvSelect2 = @.$('input.pv-sel').select2
      width: 200
      id: (item) -> item.value
      formatSelection: (item) -> item.value
      formatResult: (item) -> item.value
      allowClear: true
      multiple: true
      query: (query) =>
        data = {results: [], text: 'value'}
        if query.term.length > 0 and @selectablePVs.length > 0
          fullMatch = false
          _.each @selectablePVs, (item) ->
            if query.matcher(query.term, item['value'])
              data.results.push(item)
              if item.value.length == query.term.length
                fullMatch = true
          if not fullMatch
            data.results.unshift({id: query.term, value: query.term})
        else
          if @selectablePVs.length == 0
            data.results.push({id: query.term, value: query.term})
          else
            data.results = @selectablePVs
        query.callback(data)

    @pvSelect2.on 'change', (event) =>
      addedData = event.added
      return false unless addedData?
      if _.findLastIndex(@selectablePVs, { value: addedData.value }) == -1
        console.log 'add new propertyValue'
        @selectablePVs.push(value: addedData.value)

    @ppSelect2 = @.$('input.property-inp').select2
      width: 200
      id: (item) -> item.name
      formatSelection: (item) -> item.name
      formatResult: (item) -> item.name
      initSelection: (element, callback) ->
        callback({id: element.val(), name: element.val()})
      query: (query) ->
        data = {results: [], text: 'name'}
        if query.term.length > 0
          fullMatch = false
          _.each StockSku.Data.propertyData, (item) ->
            if query.matcher(query.term, item.name)
              data.results.push(item)
              if item.name.length == query.term.length
                fullMatch = true
          if not fullMatch
            data.results.unshift({id: query.term, name: query.term})
        else
          data.results = StockSku.Data.propertyData

        query.callback(data)

    @ppSelect2.on 'change', (event) =>
      @model.set('name', event.added.name)
      if _.findLastIndex(StockSku.Data.propertyData, { name: event.val }) == -1
        StockSku.Data.propertyData.push(name: event.val, product_property_values: [])

  clear: (e)->
    e.preventDefault()
    @model.destroy()
