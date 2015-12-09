class StockSku.Views.Category extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/category"]
  el: '#category'

  tags: []
  pre_load_tages: []

  render: ->
    @pre_load_tages = $('#pre_load_tages').val().split(',')
    @tages = $('#tages').val().split(',')
    @$el.html @template()
    @showCategorySelectOptions()
    @

  showCategorySelectOptions: ->
    category_select_options = new StockSku.Views.CategorySelectOptions
    category_select_options.render(@tages,@pre_load_tages,'#category-option')
