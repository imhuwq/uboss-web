class UXin.Views.Chat extends Backbone.View

  template: JST["#{UXin.TemplatesPath}/chat"]

  class: 'con-list-box'

  initialize: ->
    @hasSync = false
    if UXin.Services.connectionService.connected()
      @synConversations()
    else
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
        , 300
      onError: ->
        UXin.Services.noticeService.warn('获取聊天列表失败')
        UXin.ConversationList = RongIMClient.getInstance().getConversationList()
        @trigger('syncdone')

  render: ->
    @$el.html @template(conversations: UXin.ConversationList)
    @
