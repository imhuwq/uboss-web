$ ->

  $(document).on 'click', '.share-wx-btn', (e) ->
    e.preventDefault()
    if window.wx != undefined
      $(".wx-mod-pop").show()
    else
      alert('朋友圈分享只在微信浏览器可用')

  $(".wx-mod-pop").on 'click', ->
    $(this).hide()

  flash = $(".auto_close_flash_css")
  setTimeout ->
    flash.fadeOut ->
      $(this).remove()
  , 5000

  $(document).on 'click', '.flash_css', ->
    $(this).remove()

  disabledLoadMore = (e)->
    e.remove()

  $(document).on 'click', '.load-more', (e) ->
    e.preventDefault()
    element = $(this)
    if not element.hasClass('loading')
      if $(element.data('ele')).length > 4 # nothing but set it anyway
        element.addClass('loading')
        element.text('加载中...')
        reg = new RegExp("(^|&)order=([^&]*)(&|$)")
        r = window.location.search.substr(1).match(reg)
        if (r != null)
          order = unescape(r[2])
        else
          order = ''
        orderdata = $(element.data('ele')).last().attr('timestamp') || $(element.data('ele')).last().attr('orderdata')
        params = { orderdata: orderdata, order: order }
        get_url = element.data('ref')
        if get_url != null
          $.get get_url, params, (data) ->
            if $.trim(data).length
              $(element.data('container')).append(data)
              element.removeClass('loading')
              element.text('加载更多')
            else
              disabledLoadMore(element)
        else
          alert '错误：加载地址为空'
      else
        disabledLoadMore(element)

  # 浮点数运算 加
  self.floatAdd = (arg1, arg2) ->
    (floatMul(arg1, 100) + floatMul(arg2, 100)) / 100

  # 减
  self.floatSub = (arg1, arg2) ->
    (floatMul(arg1, 100) - floatMul(arg2, 100)) / 100

  # 乘
  self.floatMul = (arg1, arg2) ->
    a1 = arg1.toString()
    a2 = arg2.toString()
    n1 = if (m = a1.split(".")[1]) then m.length else 0
    n2 = if (m = a2.split(".")[1]) then m.length else 0
    Number(a1.replace(".", "")) * Number(a2.replace(".", "")) / Math.pow(10, n1 + n2)

  # 除
  self.floatDiv = (arg1, arg2) ->
    a1 = arg1.toString()
    a2 = arg2.toString()
    n1 = if (m = a1.split(".")[1]) then m.length else 0
    n2 = if (m = a2.split(".")[1]) then m.length else 0
    floatMul(Number(a1.replace(".", "")) / Number(a2.replace(".", "")), Math.pow(10, n2 - n1))

  # 限制只能输入数字
  $.fn.onlyNum = () ->
    this.limitToNumKeyup()
    this.limitToNumKeypress()

  $.fn.limitToNumKeyup = () ->
    this.keyup () ->
      this.value = this.value.replace(/[^\d]/g, '')

  $.fn.limitToNumKeypress = () ->
    this.keypress (event) ->
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
