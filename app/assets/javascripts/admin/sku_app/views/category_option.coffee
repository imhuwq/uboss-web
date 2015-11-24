class StockSku.Views.CategoryOption extends Backbone.View

  model: new StockSku.Models.CategorySelectOption

  render: (target) ->
    # $(target).append '<li >123</li>'
    console.log " @model",@model
    # $(target).append "<li class='set_category_value' data-id=\'#{@model.cid}\'>#{@model.get('name')}</li>"
    $(target).append "<option value=\'#{@model.cid}\'>#{@model.get('name')}</option>"
