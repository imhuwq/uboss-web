class StockSku.Views.CategorySelectOptions extends Backbone.View

  render: (tages,pre_load_tages,target) ->
    $(target).innerHTML = ""
    $(target).val(pre_load_tages).select2
      width: '100%'
      maximumSelectionSize: 5
      minimumInputLength: 2
      maximumInputLength: 20
      allowClear: true
      tags: tages
      createSearchChoice: (term, data) ->
        if $(data).filter(
          ()->
            this.text.localeCompare(term) == 0
            ).length == 0
          return {id:term, text:term}
