$ ->
  $check_item = $("input[name='check_item']")
  # 单选
  $("input[name='check_item']").on 'click', (e) ->
    e.preventDefault()
    index = $("input[name='check_item']").index(this)
    $check_item.eq(index).toggleClass("checked") # 伪复选
    setTotalPrice()
    setSingleTotalPrice()
    #全选判断
    i = 0
    $("input[name='check_item']").each ->
      if $(this).hasClass('checked')
        i += 1
      else
        $("#box_all").removeClass("checked")
    if i == $("input[name='check_item']").size()
      $("#box_all").addClass("checked")
    #商铺全选判读
    $(".order-list").each ->
      j = 0
      $(this).find("input[name='check_item']").each ->
        if $(this).hasClass('checked')
          j += 1
        else
          $(this).closest('.order-list').find('.seller-checkbox').removeClass("checked")

      if j == $(this).find("input[name='check_item']").size()
        $(this).find(".seller-checkbox").addClass("checked")

  # 单个商铺全选
  $('.seller-checkbox').on 'click',(e) ->
    e.preventDefault()
    $this = $(this)
    if $this.hasClass("checked")
      $this.closest(".order-list").find(".checkbox").removeClass("checked")
    else
      $this.closest(".order-list").find(".checkbox").addClass("checked")
    i= 0
    $("input[name='check_item']").each ->
      if $(this).hasClass('checked')
        i += 1
      else
        $("#box_all").removeClass("checked")
    if i == $("input[name='check_item']").size()
      $("#box_all").addClass("checked")
    setTotalPrice()
    setSingleTotalPrice()

  # 全选
  $("#box_all").on 'click', (e) ->
    e.preventDefault()
    $this = $(this)
    if $this.hasClass("checked")
      $('.checkbox').removeClass("checked")
    else
      $('.checkbox').addClass("checked")
    setTotalPrice()
    setSingleTotalPrice()

  $('.count > .min').on 'click', (e) ->
    e.preventDefault()
    $this = $(this)
    $num = $this.parent().find('.num')
    num = parseInt($num.val())
    if num == 1
      $this.attr('disabled', true)
    else
      $num.val(num - 1)
      updateItemNum($num)

  $('.count > .plus').on 'click', (e) ->
    e.preventDefault()
    $this = $(this)
    $num = $this.parent().find('.num')
    $num.val(parseInt($num.val()) + 1)
    updateItemNum($num)
    if parseInt($num.val()) != 1
      $this.parent().find('.min').removeAttr("disabled")

  updateItemNum = (e) ->
    num = e.val()
    id  = e.closest('.order-box').data('id')
    $.ajax
      url: '/carts/change_item_count'
      type: 'POST'
      data: {item_id: id, count: num}
      success: (res) ->
        if res['status'] == "ok"
          $('.order-box[data-id="'+res["item_id"]+'"]').find('.num').val(res["count"])
          if res['alert'].length != 0
            flashPopContent('<div class="pop-text">'+res['alert']+'</div>')
        else
          alert(res['error'])
        setSingleTotalPrice()
        setTotalPrice()

  # 监听input值变化
  $("input[name='num']").on 'change', (e) ->
    e.preventDefault()
    $this = $(this)
    this.value = this.value.replace(/[^\d]/g, '')
    if this.value == '' || this.value == "0"
      this.value = 1
    updateItemNum($this)

  $('button.btn-delete').on 'click', () ->
    id = $(this).closest('.order-box').attr('data-id')
    if confirm("确定要删除该商品吗？")
      $.ajax
        url: '/carts/delete_item'
        type: 'POST'
        data: {item_id: id}
        success: (res) ->
          if res['status'] == "ok"
            $('.c_delete_'+res['id']).closest('.order-box').remove()
            checkDeleteOrderList()
            setTotalPrice()
            setSingleTotalPrice()
          else
            alert(res['message'])
            location.reload()
        error: (data, status, e) ->
          alert('操作错误')
      return false
    else
      return false

  checkDeleteOrderList = ->
    $('.order-list').each ->
      $this = $(this)
      if $this.find('.order-box').length == 0
        $this.addClass('hidden')
      if $('.order-box').length == 0
        $('.cart-list').empty()
        $('.order-price').empty()
        $('.empty-cart').removeClass('hidden')

  $("input[name='num']").onlyNum()

  # 总价计算
  setTotalPrice = (e) ->
    total_price=0
    $(".order-box .checked").each ->
      num   = parseInt($(this).parent().find('.num').val())
      price = $(this).parent().find('.product-price').text()
      total_price = floatAdd(total_price, floatMul(price, num))
    $('.total_price').text(total_price)

  # 单商铺计算
  setSingleTotalPrice = (e) ->
    $('.single_total_price').each ->
      single_total_price = 0
      $(this).closest('.order-list').children('.order-box').children('.checked').each ->
        num   = parseInt($(this).parent().find('.num').val())
        price = $(this).parent().find('.product-price').text()
        single_total_price = floatAdd(single_total_price, floatMul(price, num))
      $(this).text(single_total_price)

  $('.new_order').on 'click', (e) ->
    e.preventDefault()
    checked_items = $(".checked[name='check_item']")
    check_items_ids = []
    for item, i in checked_items
      check_items_ids.push($(item).closest('.order-box').data('id'))
    if check_items_ids.length == 0
      flashPopContent('<div class="pop-text">请勾选您要购买商品</div>')
    else
      location.href = "/orders/new?item_ids=" + check_items_ids.join(',')
