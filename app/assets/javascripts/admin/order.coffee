$(document).on 'ready page:load', ->

  $('body').delegate '.select_all_orders', 'click', (event) ->
    parent_element = $('.list-table')[0]
    checkboxs = parent_element.getElementsByTagName('input')
    if $(this).find('input')[0].checked
      for ch in checkboxs
        ch.checked = true
    else
      for ch in checkboxs
        ch.checked = false

  $(document).on 'click', '.express-order-btn', (e) ->
    e.preventDefault()
    form = $("#ship-express-modal form")
    form.attr('action', $(this).attr("href"))
    $("#ship-express-modal").modal("show")
