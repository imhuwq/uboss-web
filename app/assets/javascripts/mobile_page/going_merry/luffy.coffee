class GoingMerry.Luffy
  constructor: ->
    @resetInvokeSharing()

  invokeSharing: ->
    if window.wx
      wx.showOptionMenu()
      wx.onMenuShareTimeline(
        title: @sharing_title
        link: @sharing_link
        imgUrl: @sharing_imgurl
      )
      wx.onMenuShareAppMessage(
        title: @sharing_title
        link: @sharing_link
        desc: @sharing_desc
        imgUrl: @sharing_imgurl
      )

  resetInvokeSharing: (info = {}) ->
    @sharing_title = info.title || $('meta[name=sharing_title]').attr('content')
    @sharing_link = info.link || $('meta[name=sharing_link]').attr('content')
    @sharing_imgurl = info.imgurl || $('meta[name=sharing_imgurl]').attr('content')
    @sharing_desc = info.desc || $('meta[name=sharing_desc]').attr('content')
