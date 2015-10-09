$ ->
  $check_item = $("input[name='check_item']")
  # 单选
  $("input[name='check_item']").on 'click', (e) ->
    e.preventDefault()
    $(this).toggleClass("checked") # 伪复选
    setTotalPrice()
    setSingleTotalPrice()
    #全选判断  
    i= 0
    $("input[name='check_item']").each ->
      if $(this).hasClass('checked')
        i+=1;
      else
        all=false
        $("#box_all").removeClass("checked")
    if i == $("input[name='check_item']").size()
      $("#box_all").addClass("checked")
    #商铺全选判读
    $(".order-list").each ->        
      j=0
      $(this).find("input[name='check_item']").each ->
        if $(this).hasClass('checked')
          j+=1;
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
    setTotalPrice()
    setSingleTotalPrice()
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
      setTotalPrice()
      setSingleTotalPrice()

  $('.count > .plus').on 'click', (e) ->
    e.preventDefault()
    $this = $(this)
    $num = $this.parent().find('.num')
    $num.val(parseInt($num.val())+1)
    if parseInt($num.val()) != 1
      $this.parent().find('.min').removeAttr("disabled")
    setTotalPrice()
    setSingleTotalPrice()

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

  # 监听input值变化
  $("input[name='num']").on 'change', (e) ->
    e.preventDefault()
    this.value = this.value.replace(/[^\d]/g, '')
    if this.value == '' || this.value == "0"
      this.value = 1
    setTotalPrice($(this))

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

