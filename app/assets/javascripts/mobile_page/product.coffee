$ ->
  # 加入购物车 TODO
  $('.js-add-cart').on 'click', (e)->
    e.preventDefault()
    product_id = Number($("input[name='product[id]']").val())
    count = Number($("input[name='product[count]']").val())

    if count >= 1
      $.ajax
        url: '/cart_items'
        type: 'POST'
        data: {product_id: product_id, count: count}
        success: (res) ->
          if res['status'] == "ok"
            alert('添加成功，购物车有'+res['cart_items_count']+'件商品')
            # TODO do something. 购物车标记空与不空
          else
            location.reload()
            alert(res['message'])
        error: (data, status, e) ->
          alert("ERROR")
    else
      alert "请填写正确的商品数量"

  $(document).on 'ajaxSuccess', '.like-product-btn', (event, xhr, settings, data) ->
    flash_content = $('<div class="pop-alert flash_css"><div class="pop-content"></div>')
    flash_content.appendTo('body')
    if data.favoured
      $(this).addClass('active')
      flash_content.find('.pop-content').append '''
        <div class="pop-text">您喜欢了该商品，可以在店铺主页<br/>我的喜欢模块找到本商品</div>
      '''
    else
      $(this).removeClass('active')
      flash_content.find('.pop-content').append '''
        <div class="pop-text line-2 gray">您取消了该喜欢商品</div>
      '''
    setTimeout ->
      flash_content.remove()
    , 3000

  $(document).on 'ajaxError', '.like-product-btn', () ->
    alert "操作失败"

  $('#show_inventory_cart').on 'click', ->
    $('#confirm-inventory').removeClass('buy-now')
    $('#confirm-inventory').addClass('add-to-cart')
    showInventory()

  $('#show_inventory').on 'click', ->
    $('#confirm-inventory').removeClass('add-to-cart')
    $('#confirm-inventory').addClass('buy-now')
    showInventory()

  showInventory = ->
    $('#inventory').removeClass('hidden')
    $('.fixed-container').css('-webkit-filter', 'blur(3px)')

  $('.sku').on 'click', ->
    console.log($(this).attr('id'));
    product_inventory_id = $(this).attr('id')
    $('#product_inventory_id').val(product_inventory_id);
    $('.item_click').removeClass('item_click')
    $(this).addClass('item_click')
    $('#price_range').addClass('hidden')
    $('.real_price').addClass('hidden')
    $("#price_#{product_inventory_id}").removeClass('hidden')

  $('#confirm-inventory').on 'click', ->
    product_inventory_id = $('#product_inventory_id').val();
    if product_inventory_id == ''
      alert "请勾选您要的商品信息！"
    else
      want_buy = confirm "确认购买么？"
      if want_buy
          $('.product_inventory').submit()
