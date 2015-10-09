$ ->
  $check_item = $("input[name='check_item']")
  # 单选
  $("input[name='check_item']").on 'click', (e) ->
    e.preventDefault()
    index = $("input[name='check_item']").index(this)
    $check_item.eq(index).toggleClass("checked") # 伪复选
    setTotalPrice()
    setSingleTotalPrice()
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
        i+=1;
      else
        all=false
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
      $num.val(num-1)
      updateItemNum($num)
      setTotalPrice()
      setSingleTotalPrice()

  $('.count > .plus').on 'click', (e) ->
    e.preventDefault()
    $this = $(this)
    $num = $this.parent().find('.num')
    $num.val(parseInt($num.val())+1)
    updateItemNum($num)
    if parseInt($num.val()) != 1
      $this.parent().find('.min').removeAttr("disabled")
    setTotalPrice()
    setSingleTotalPrice()

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
            alert(res['alert'])
        else
          alert(res['error'])

  # 监听input值变化
  $("input[name='num']").on 'change', (e) ->
    e.preventDefault()
    $this = $(this)
    this.value = this.value.replace(/[^\d]/g, '')
    if this.value == '' || this.value == "0"
      this.value = 1
    updateItemNum($this)
    setSingleTotalPrice()
    setTotalPrice($this)

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
            setTotalPrice()
            setSingleTotalPrice()
            changeSubmitBtn()
          else
            location.reload()
            alert(res['message'])
        error: (data, status, e) ->
          alert('ERROR')
      return false
    else
      return false

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

  $("input[name='num']").onlyNum()

  setTotalPrice = (e) ->
    # 总价计算
    total_price=0
    $(".order-box .checked").each ->
      num = parseInt($(this).parent().find('.num').val())
      price= $(this).parent().find('.product-price').text()
      total_price+=num*price
    $('.total_price').text(total_price)
  setSingleTotalPrice = (e) ->
    # 单商铺计算
    $('.single_total_price').each ->
      single_total_price=0
      $(this).closest('.order-list').children('.order-box').children('.checked').each ->
        num = parseInt($(this).parent().find('.num').val())
        price= $(this).parent().find('.product-price').text()
        single_total_price+=num*price
      $(this).text(single_total_price)

  $("input[type='checkbox']").on 'click', (e) ->
    e.preventDefault()
    changeSubmitBtn()

  changeSubmitBtn = () ->
    if $(".checked[name='check_item'").length == 0
      $('.cart-btn').attr('href', 'javascript:;')
    else
      $('.cart-btn').attr('href', '/orders/new')

