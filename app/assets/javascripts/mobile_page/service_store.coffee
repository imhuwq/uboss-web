$ ->

  $('.service-store-buy-btn').on 'click', ->
    $product = $(this).closest('.service-store-product')
    $('.buy_now_goods_img').attr('src', $product.find('img').attr('src'))
    $('.buy_now_goods_dl #price_range').html($product.find('.product h2 b').html())
    $('.buy_now_goods_dl .product_name').html($product.find('.product .title').html())
    $('#inventory').data('price', $product.find('.product h2 b').html())
    $('input[name="product_id"]').val($product.data('pid'))
    $('input[name="product_inventory_id"]').val($product.data('piid'))
    $('input[name="amount"]').val('1')

    $('#inventory').removeClass('hidden')
    $('.fixed-container').css('-webkit-filter', 'blur(3px)')
    $('html').addClass('lock')
    minNum()
    plusNum()

  $('.btn_cancle_buy_now').on 'click', ->
    $('#inventory').addClass('hidden')
    $('.fixed-container').css('-webkit-filter', 'blur(0px)')
    $('html').removeClass('lock')

  minNum = ->
    $('.count_min').on 'click', ->
      num = parseInt($('.count-box .count_num').val())
      if num < 2
        flashPopContent('<div class="pop-text">数量必须大于1</div>')
        $('.count-box .count_num').val(1)
        $('#count_amount').val(1)
      else
        $('.count-box .count_num').val(num-1)
        $('#count_amount').val(num - 1)
        calculateTotalPrice(num - 1)

  plusNum = ->
    $('.count_plus').on 'click', ->
      num = parseInt($('.count-box .count_num').val())
      $('.count-box .count_num').val(num + 1)
      $('#count_amount').val(num + 1)
      calculateTotalPrice(num + 1)

  calculateTotalPrice = (num)->
    price = parseFloat($('#inventory').data('price'))
    total_price = floatMul(price, num)
    $('.count-box .count_num').val(num)
    $('.buy_now_goods_dl #price_range').html(total_price)
