class StockSku.Views.CategorySelectOptions extends Backbone.View

  # template: JST["#{StockSku.TemplatesPath}/category_select_options"]
  #



  render: (tages,pre_load_tages,target) ->
    $(target).innerHTML = ""
    console.log "pre_load_tages", pre_load_tages
    console.log "tages", tages

    $(target).val(pre_load_tages).select2
      width: '100%'
      maximumSelectionSize: 5
      allowClear: true
      tags: tages
      createSearchChoice: (term, data) ->
        if $(data).filter(
          ()->
            this.text.localeCompare(term) == 0
            ).length == 0
          return {id:term, text:term}



  @formatSelectionTooBig: ->
    alert "too big"
