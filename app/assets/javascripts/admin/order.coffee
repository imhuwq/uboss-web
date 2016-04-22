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
    info = $(this).attr('data-buyer-info')
    mes = $(this).attr('data-message')
    form.find('.ship_express_buyer_info').text(' ' + info)
    form.find('.ship_express_buyer_message').text(' ' + mes)
    $("#ship-express-modal").modal("show")

  $(document).on 'click', '.ship_express_method_btn button', (e) ->
    e.preventDefault()
    method = $(this).attr('data-method')
    $('.ship_express_method_btn input').val(method)
    if method == 'no_need'
      $("button[data-method='need']").addClass('btn-link')
      $(this).removeClass('btn-link')
      $('#ship-express-modal .express_info').hide()
    else
      $("button[data-method='no_need']").addClass('btn-link')
      $(this).removeClass('btn-link')
      $('#ship-express-modal .express_info').show()
