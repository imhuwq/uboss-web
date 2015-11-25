class UXin.Views.Chat extends Backbone.View

  template: JST["#{UXin.TemplatesPath}/chat"]

  conversation_template: JST["#{UXin.TemplatesPath}/conversation_item"]

  class: 'con-list-box'

  initialize: ->
    @hasSync = false
    if UXin.Services.connectionService.connected()
      @synConversations()
    else
      @listenTo UXin.Services.connectionService, 'success', @synConversations
    @listenTo UXin.Services.connectionService, 'success', @synConversations

  synConversations: ->
    return true if @hasSync
    console.log "start syncConversationList ..."
    UXin.Services.noticeService.note('获取聊天列表中...')
    RongIMClient.getInstance().syncConversationList
      onSuccess: =>
        UXin.Services.noticeService.flashNote('获取聊天列表成功')
        @hasSync = true
        setTimeout =>
          UXin.ConversationList = RongIMClient.getInstance().getConversationList()
          for item in UXin.ConversationList
            switch item.getConversationType()
              when RongIMClient.ConversationType.CHATROOM
                item.setConversationTitle('聊天室')
              when RongIMClient.ConversationType.CUSTOMER_SERVICE
                item.setConversationTitle('客服')
              when RongIMClient.ConversationType.DISCUSSION
                item.setConversationTitle('讨论组:' +  item.getTargetId())
              when RongIMClient.ConversationType.GROUP
                item.setConversationTitle(namelist[item.getTargetId()] || '未知群组')
              when RongIMClient.ConversationType.PRIVATE
                item.getConversationTitle() || item.setConversationTitle('陌生人:'+item.getTargetId())
          @trigger('syncdone')
          @listenTo UXin.Services.messageServices, 'new', @render
        , 300
      onError: =>
        UXin.Services.noticeService.warn('获取聊天列表失败')
        UXin.ConversationList = RongIMClient.getInstance().getConversationList()
        @listenTo UXin.Services.messageServices, 'new', @render
        @trigger('syncdone')

  render: ->
    @$el.html @template()
    for conversation in UXin.ConversationList
      userInfo = @getConversationUserInfo(conversation)
      @$el.find('#conversation-list').append @conversation_template(
        targetId: conversation.getTargetId()
        conversationType: conversation.getConversationType().valueOf()
        conversationTitle: userInfo.nickname || conversation.getConversationTitle() || '陌生人'
        avatar: if userInfo.avatar then "#{userInfo.avatar}-thumb" else "/t/noimage.gif"
        unreadMessageCount: conversation.getUnreadMessageCount()
        latestTime: conversation.getLatestTime()
      )
    @

  getConversationUserInfo: (conversation) ->
    userInfo = UXin.Services.userInfoService.getUserInfo conversation.getTargetId(), (userInfo)=>
      $("li[targetid='#{userInfo.id}'] .user_img img").attr('src', "#{userInfo.avatar}-thumb")
      $("li[targetid='#{userInfo.id}'] .u-name").html(userInfo.nickname)

    if userInfo?
      userInfo
    else
      {}
