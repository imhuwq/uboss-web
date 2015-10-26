class StockSku.Views.PrivilegeItem extends Backbone.View

  tagName: 'tr'

  template: JST["#{StockSku.TemplatesPath}/privilege_item"]

  events:
    'blur input.pri-total': 'setPrivilegeAmount'

  initialize: (attributes)->
    @listenTo @model, "change:id", @render
    @listenTo @model, "change:price", @render
    @listenTo @model, "sharingAmountChanged", @render

  render: ->
    data = @model.toJSON()
    data.read_only = data.read_only || Number(data.price || 0) <= 0
    @$el.html @template(data)
    @

  setPrivilegeAmount: (e)->
    value = $(e.target).val()
    return false unless !!value
    @model.set 'share_amount_total', Number(value)
    console.log 'set share_amount_total', Number(value)
