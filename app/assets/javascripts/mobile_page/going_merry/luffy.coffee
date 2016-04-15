class GoingMerry.Luffy
  constructor: ->
    @resetInvokeSharing()

  invokeSharing: ->
    if window.wx?
      @showOptionMenu()
      wx.onMenuShareTimeline(
        title: @sharing_title
        link: @sharing_link
        imgUrl: @sharing_imgurl
      )
      @setSharingInfo(
        title: @sharing_title
        link: @sharing_link
        desc: @sharing_desc
        imgUrl: @sharing_imgurl
      )
    else
      $('.share-wx-btn').remove()
      $('.sharing-button-wx').remove()

  invokeDefaultSharing: ->
    if window.wx
      wx.onMenuShareTimeline(
        title: 'UBOSS商城 | 基于人，超乎想象'
        link: "http://#{window.location.host}"
        imgUrl: $('meta[name=logo]').attr('content')
      )
      @setSharingInfo(
        title: 'UBOSS商城 | 基于人，超乎想象'
        desc: """
          新概念移动社会化电商平台，旨在帮助商家零成本轻松建立线上分销商场。
          用户可以通过分享商品获取返利，轻松为商家增加线上商品销量。
        """
        link: "http://#{window.location.host}"
        imgUrl: $('meta[name=logo]').attr('content')
      )

  showOptionMenu: ->
    wx.showOptionMenu()

  disableSharing: ->
    wx.hideOptionMenu()

  resetInvokeSharing: (info = {}) ->
    if info.metaContainer?
      metaContainer = info.metaContainer
    else
      metaContainer = $('html')
    @sharing_title = info.title || metaContainer.find('meta[name=sharing_title]').attr('content')
    @sharing_link = info.link || metaContainer.find('meta[name=sharing_link]').attr('content')
    @sharing_imgurl = info.imgurl || metaContainer.find('meta[name=sharing_imgurl]').attr('content')
    @sharing_desc = info.desc || metaContainer.find('meta[name=sharing_desc]').attr('content')
    $('.share-content').find('.sharing-link').text(@sharing_link)
    @invokeSharing()

  setSharingInfo: (with_detail_info)->
    wx.onMenuShareAppMessage(with_detail_info)
    wx.onMenuShareQQ(with_detail_info)
    wx.onMenuShareWeibo(with_detail_info)
    wx.onMenuShareQZone(with_detail_info)

  showWxPopTip: ->
    if window.wx?
      $(".wx-mod-pop").show()
    else
      alert('分享到微信，请在微信浏览器中打开此页面')

  toggleSharingContent: ->
    $('.share-container').toggleClass('hidden')

  openUrl : (url, popup) ->
    if popup == "true"
      window.open(url,'popup','height=500,width=500')
    else
      window.open(url)
      false

  shareToWeibo: ->
    @openUrl(
      "http://service.weibo.com/share/share.php?url=#{@sharing_link}&type=3&pic=#{@sharing_imgurl}&title=#{@sharing_title}",
      'false'
    )

  shareToQQ: ->
    @openUrl(
      "http://share.v.t.qq.com/index.php?c=share&a=index&url=#{@sharing_link}&title=#{@sharing_title}&pic=#{@sharing_imgurl}",
      'fasle'
    )

  shareToQzone: ->
    @openUrl(
      "http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=#{@sharing_link}&title=#{@sharing_imgurl}&pics=#{@sharing_imgurl}&summary=#{@sharing_desc}",
      'false'
    )

  bindPCardTaker: (btn, options = {}) ->
    $(btn).on 'click', (e) ->
      e.preventDefault()
      element = $(this)
      user_tel= $('.input-tel-value').val()
      if !element.data('uid')
        telReg = !!user_tel.match(/^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/)
        if !telReg
          alert("请输入正确的手机号码")
          return false
      options.beforeSendFuc(user_tel) if typeof(options.beforeSendFuc) == 'function'
      UBoss.chopper.showSpinner()
      return false if element.hasClass('loading')
      element.addClass('loading')
      $.ajax
        url: element.attr("href")
        type: 'GET'
        data:
          mobile: user_tel
          product_id: element.data("pid")
          seller_id: element.data("sid")
      .done (data) ->
        $('meta[name=sharing_link]').attr( 'content', "#{data.sharing_link}?redirect=#{encodeURIComponent(element.data('path'))}")
        $('.input-tel-value').remove()
        UBoss.luffy.resetInvokeSharing()
        options.successFuc.call(element, data) if typeof(options.successFuc) == 'function'
      .fail (xhr, textStatus) ->
        if typeof(options.failFuc) == 'function'
          options.failFuc(user_tel)
        else
          alert('操作失败')
      .always ->
        UBoss.chopper.hideSpinner()
        element.removeClass('loading')
        options.alwaysFuc() if typeof(options.alwaysFuc) == 'function'

$ ->
  UBoss.luffy = new GoingMerry.Luffy
