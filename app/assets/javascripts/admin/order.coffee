$(document).on 'ready page:load', ->
  $('body').delegate '.select_all_orders', 'click', (event) ->
    parent_element = this.parentElement.parentElement.parentElement.parentElement
    checkboxs = parent_element.getElementsByTagName('input')
    if $(this).find('input')[0].checked
      for ch in checkboxs
        ch.checked = true
    else
      for ch in checkboxs
        ch.checked = false
