$ ->
  $check_item = $("input[name='check_item']")

  # 单选
  $("input[name='check_item']").on 'click', (e) ->
    e.preventDefault()
    index = $("input[name='check_item']").index(this)
    $check_item.eq(index).toggleClass("checked") # 伪复选
    setTotalPriceOfSelect()

  # 全选
  $("#box_all").on 'click', (e) ->
    e.preventDefault()
    $this = $(this)
    $this.toggleClass("checked")
    if $this.hasClass("checked")
      $check_item.removeClass("checked")
      $check_item.addClass("checked")
    else
      $check_item.removeClass("checked")
    setTotalPriceOfSelect()

  $('.c_count > .min').on 'click', (e) ->
    e.preventDefault()
    $this = $(this)
    $num = $this.parent().find('.num')
    num = parseInt($num.val())
    if num == 1
      $this.attr('disabled', true)
    else
      $num.val(num-1)
      setTotalPrice($num)

  $('.c_count > .plus').on 'click', (e) ->
    e.preventDefault()
    $this = $(this)
    $num = $this.parent().find('.num')
    $num.val(parseInt($num.val())+1)
    if parseInt($num.val()) != 1
      $this.parent().find('.min').removeAttr("disabled")
    setTotalPrice($num)

  $('a.c_delete').on 'click', () ->
    id = $(this).closest('table').attr('data-id')
    if confirm("确定要删除该商品吗？")
      $.ajax
        url: '/carts/delete_item'
        type: 'POST'
        data: {item_id: id}
        success: (res) ->
          if res['status'] == "ok"
            $('.c_delete_'+res['id']).closest('li').remove()
            appendTotalPriceText(res["total_price"])
            changeSubmitBtn()
          else
            location.reload()
            alert(res['message'])
        error: (data, status, e) ->
          alert('ERROR')
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
    #  clipboard = window.clipboardData.getData("Text")
    #  if /^\d+$/.test(clipboard)
    #    return true
    #  else
    #    return false

  $("input[name='num']").onlyNum()

  # 监听input值变化
  $("input[name='num']").on 'change', (e) ->
    e.preventDefault()
    this.value = this.value.replace(/[^\d]/g, '')
    if this.value == '' || this.value == "0"
      this.value = 1
    setTotalPrice($(this))

  setTotalPrice = (e) ->
    num = e.val()
    id  = e.attr('data-id')
    $.ajax
      url: '/carts/change_item_count'
      type: 'POST'
      data: {item_id: id, count: num}
      success: (res) ->
        if res['status'] == "ok"
          appendTotalPriceText(res["total_price"])
        else
          location.reload()
          console.log('error')
      error: (data, status, e) ->
        # do something

  # 计算总价
  setTotalPriceOfSelect = ()->
    id_array = new Array()
    $(".checked[name='check_item']").each ->
      id_array.push(Number($(this).attr('data-id')))
    $.ajax
      url: '/carts/items_select'
      type: 'POST'
      data: {id_array: id_array}
      success: (res) ->
        if res['status'] == "ok"
          appendTotalPriceText(res["total_price"])
        else
          location.reload()
      error: (data, status, e) ->
        # do something

  # 修改总价
  appendTotalPriceText = (total_price) ->
    $('.c_total_price').text("￥"+total_price)

  $("input[type='checkbox']").on 'click', (e) ->
    e.preventDefault()
    changeSubmitBtn()

  changeSubmitBtn = () ->
    if $(".checked[name='check_item']").length == 0
      $('.cart-btn').attr('href', 'javascript:;')
    else
      $('.cart-btn').attr('href', '/orders/new')

