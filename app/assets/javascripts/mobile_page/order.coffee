$ ->

  $('#new_order_form .jia').on 'click', (e)->
    e.preventDefault()
    amount = parseInt($('#amount').val())
    $('#amount').val(amount + 1)
    calulateTotalPrice(amount + 1)

  $('#new_order_form .jian').on 'click', (e)->
    e.preventDefault()
    amount = parseInt($('#amount').val())
    if amount > 1
      $('#amount').val(amount - 1)
      calulateTotalPrice(amount - 1)

  $('.subOrd_box2 #amount').on 'keyup', (event) ->
    amount = $(this).val()
    calulateTotalPrice(amount)

  calulateTotalPrice = (amount) ->
    price = Number($('#order_form_real_price').val())
    $('#total_price').html(amount * price + Number($('#order_form_product_traffic_expense').val()))
