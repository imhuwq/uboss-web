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
      alert('朋友圈分享只在微信浏览器可用')

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

$ ->
  UBoss.luffy = new GoingMerry.Luffy
