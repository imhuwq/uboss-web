class GoingMerry.Luffy
  constructor: ->
    @resetInvokeSharing()

  invokeSharing: ->
    if window.wx
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
    @sharing_title = info.title || $('meta[name=sharing_title]').attr('content')
    @sharing_link = info.link || $('meta[name=sharing_link]').attr('content')
    @sharing_imgurl = info.imgurl || $('meta[name=sharing_imgurl]').attr('content')
    @sharing_desc = info.desc || $('meta[name=sharing_desc]').attr('content')
    @invokeSharing()

  setSharingInfo: (with_detail_info)->
      wx.onMenuShareAppMessage(with_detail_info)
      wx.onMenuShareQQ(with_detail_info)
      wx.onMenuShareWeibo(with_detail_info)
      wx.onMenuShareQZone(with_detail_info)

UBoss.luffy = new GoingMerry.Luffy
