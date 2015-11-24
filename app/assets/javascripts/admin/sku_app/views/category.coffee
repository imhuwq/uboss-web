class StockSku.Views.Category extends Backbone.View

  template: JST["#{StockSku.TemplatesPath}/category"]
  el: '#category'

  tags: []
  pre_load_tages: []


  events:
    # "click #category-value" : "showCategorySelectOptions"
    "click .set_category_value" : "set_category_value"

  # initialize: ->
  #   category_select_options = new StockSku.Views.CategorySelectOptions

  render: ->
    console.log "$('#category_hash').val()", $('#category_hash').val()
    @pre_load_tages = $('#pre_load_tages').val().split(" ")
    @tages = $('#tages').val().split(" ")
    @$el.html @template()
    @showCategorySelectOptions()
    @

  showCategorySelectOptions: ->
    console.log "showCategorySelectOptions"
    category_select_options = new StockSku.Views.CategorySelectOptions
    category_select_options.render(@tages,@pre_load_tages,'#category-option')

  set_category_value: (tar) ->
    $('#category-value').val(@collection.get($(tar.toElement).data('id')).get('name'))
