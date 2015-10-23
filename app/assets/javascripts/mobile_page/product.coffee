$ ->

  @flashPopContent = (html_str) ->
    flash_content = $('<div class="pop-alert flash_css text-center"><div class="pop-content"></div>')
    flash_content.appendTo('body')
    flash_content.find('.pop-content').append(html_str)
    setTimeout ->
      flash_content.remove()
    , 3000

  $(document).on 'ajaxSuccess', '.like-product-btn', (event, xhr, settings, data) ->
    if data.favoured
      $(this).addClass('active')
      flashPopContent('<div class="pop-text">您喜欢了该商品，可以在店铺主页<br/>我的喜欢模块找到本商品</div>')
    else
      $(this).removeClass('active')
      flashPopContent('<div class="pop-text line-2 gray">您取消了该喜欢商品</div>')

  $(document).on 'ajaxError', '.like-product-btn', () ->
    alert "操作失败"

  $('#show_inventory_cart').on 'click', ->
    $('#confirm-inventory').removeClass('buy-now')
    $('#confirm-inventory').addClass('add-to-cart')
    showInventory()
    bindAddToCartBtn()

  $('#show_inventory').on 'click', ->
    $('#confirm-inventory').removeClass('add-to-cart')
    $('#confirm-inventory').addClass('buy-now')
    showInventory()
    bindBuyNowBtn()

  showInventory = ->
    $('#inventory').removeClass('hidden')
    $('.fixed-container').css('-webkit-filter', 'blur(3px)')
    $('html').addClass('lock')

  $('.count-box .count_min').on 'click',->
    num=parseInt($('.count-box .count_num').val())
    if num < 2 
      alert('数量必须大于1')
      $('.count-box .count_num').val(1)
      $('#count_amount').val(1)
    else
      $('.count-box .count_num').val(num-1)
      $('#count_amount').val(num-1)

  $('.count-box .count_plus').on 'click',->
    num=parseInt($('.count-box .count_num').val())
    $('.count-box .count_num').val(num+1)
    $('#count_amount').val(num+1)

  $.fn.onlyNum = () ->
    $(this).keyup () ->
      $this = $(this)
      this.value = this.value.replace(/[^\d]/g, '')

  # 限制只能输入数字
  $.fn.onlyNum = () ->
    $(this).keypress (event) ->
      eventObj = event || e
      keyCode = eventObj.keyCode || eventObj.which
      if (keyCode >= 48 && keyCode <= 57)
        return true
      else
        return false
    .focus () ->
      this.style.imeMode = 'disabled' # 禁用输入法
    .bind "paste", () ->              # 禁用粘贴
      return false

  $(".count-box .count_num").on 'change',->
    $this = $(this)
    this.value = this.value.replace(/[^\d]/g, '')
    $('#count_amount').val(this.value)
    if this.value == '' || this.value == "0"
      this.value = 1
      $('#count_amount').val(1)

  $(".count-box .count_num").onlyNum()

  $('.sku').on 'click', ->
    console.log($(this).attr('id'));
    product_inventory_id = $(this).attr('id')
    $('#product_inventory_id').val(product_inventory_id);
    $('.item_click').removeClass('item_click')
    $(this).addClass('item_click')
    $('#price_range').addClass('hidden')
    $('.real_price').addClass('hidden')
    $("#price_#{product_inventory_id}").removeClass('hidden')

  # 立即购买
  bindBuyNowBtn = ->
    $('.buy-now').on 'click', ->
      if checkInventoriesSelect()
        $('.product_inventory').submit()

  # 加入购物车
  bindAddToCartBtn = ->
    $('.add-to-cart').on 'click', (e)->
      e.preventDefault()
      if checkInventoriesSelect()
        product_inventory_id = Number($('input[name="product_inventory_id"]').val())
        product_id = Number($('input[name="product_id"]').val())
        count = Number($('.count_num').val())
        if count >= 1
          $.ajax
            url: '/cart_items'
            type: 'POST'
            data: {product_inventory_id: product_inventory_id, product_id: product_id, count: count}
            success: (res) ->
              if res['status'] == "ok"
                flashPopContent('<div class="pop-text">添加成功<br/>购物车有'+res['cart_items_count']+'件商品</div>')
              else
                flashPopContent('<div class="pop-text">'+res['message']+'</div>')
                location.reload()
            error: (data, status, e) ->
              alert("操作错误")
        else
          flashPopContent('<div class="pop-text">请填写正确的商品数量</div>')

  checkInventoriesSelect = ->
    product_inventory_id = $('#product_inventory_id').val();
    if product_inventory_id == ''
      alert "请勾选您要的商品信息！"
      return false
    else
      return true
