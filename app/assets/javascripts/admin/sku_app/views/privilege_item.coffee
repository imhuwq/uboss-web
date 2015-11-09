class StockSku.Views.PrivilegeItem extends Backbone.View

  tagName: 'tr'

  template: JST["#{StockSku.TemplatesPath}/privilege_item"]

  events:
    'blur input.pri-total': 'setPrivilegeAmount'

  initialize: (attributes)->
    @listenTo @model, "change:id", @render
    @listenTo @model, "change:price", @render
    @listenTo @model, "sharingAmountChanged", @render
    @listenTo @model, "invalid", @showError

  render: ->
    data = @model.toJSON()
    data.read_only = data.read_only || Number(data.price || 0) <= 0
    @$el.html @template(data)
    @

  showError: (model, error)->
    if !!error.share_amount_total and @$('input.pri-total').parent().find('.error').length == 0
      @$('input.pri-total').parent().append("<span class='error'>#{error.share_amount_total}</span>")

  setPrivilegeAmount: (e)->
    value = $(e.target).val()
    return false unless !!value
    value = Number(value).toFixed(2)
    result = @model.set 'share_amount_total', Number(value), validate: true
    if not !!result
      @$('input.pri-total').val(@model.get('share_amount_total'))
    else
      @$('input.pri-total').val(value)
