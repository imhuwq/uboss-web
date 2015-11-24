class UXin.Views.Conversation extends Backbone.View

  template: JST["#{UXin.TemplatesPath}/conversation"]

  message_template: JST["#{UXin.TemplatesPath}/message"]

  className: 'conversation-box'

  events:
    'click #send-msg-btn': 'sendMessage'

  messageCache: UXin.Data.messageCache

  currentConversation: null

  initialize: ->
    @listenTo UXin.Services.messageServices, 'new', (message)->
      if message.getTargetId() == UXin.currentConversationTargetId
        @addMessages(message)
        @currentConversation.setUnreadMessageCount(0) if @getCurrentConversation()?

  clearCurrentConversation: ->
    UXin.currentConversationTargetId = null
    @currentConversation = null

  render: ->
    @$el.html @template()
    if UXin.Services.connectionService.connected()
      @getMessages()
    else
      @listenTo UXin.Services.connectionService, 'success', @getMessages
    @

  getCurrentConversation: ->
    conversationType = RongIMClient.ConversationType.PRIVATE.valueOf()
    @currentConversation ?= RongIMClient.getInstance().getConversation RongIMClient.ConversationType.setValue(conversationType), UXin.currentConversationTargetId

  sendMessage: ->
    tMsg = $('#send-msg').val()
    unless !!tMsg
      UXin.Services.noticeService.flashWarn('不允许发送空内容')
      return false

    targetId = UXin.currentConversationTargetId
    unless !!targetId
      UXin.Services.noticeService.flashWarn('请选中需要聊天的人')
      return false

    conversationtype = RongIMClient.ConversationType.PRIVATE
    if RongIMClient.getInstance().getConversation(RongIMClient.ConversationType.setValue(conversationtype.valueOf()), UXin.currentConversationTargetId) is null
      RongIMClient.getInstance().createConversation(RongIMClient.ConversationType.setValue(conversationtype.valueOf()), UXin.currentConversationTargetId, '新会话')

    content = new RongIMClient.MessageContent RongIMClient.TextMessage.obtain(tMsg)
    RongIMClient.getInstance().sendMessage conversationtype, targetId, content, null,
      onSuccess: =>
        console.log 'Send successfully'
        $('#send-msg').val('')
        message = content.getMessage()
        @addMessages(message)
        if !@messageCache[message.getConversationType().valueOf() + "_" + message.getTargetId()]
          @messageCache[message.getConversationType() + "_" + message.getTargetId()] = [message]
        else
          @messageCache[message.getConversationType().valueOf() + "_" + message.getTargetId()].push(message)
        return
      onError: (errorCode) ->
        info = ''
        switch errorCode
          when RongIMClient.callback.ErrorCode.TIMEOUT            then info = '超时'
          when RongIMClient.callback.ErrorCode.UNKNOWN_ERROR      then info = '未知错误'
          when RongIMClient.SendErrorStatus.REJECTED_BY_BLACKLIST then info = '在黑名单中，无法向对方发送消息'
          when RongIMClient.SendErrorStatus.NOT_IN_DISCUSSION     then info = '不在讨论组中'
          when RongIMClient.SendErrorStatus.NOT_IN_GROUP          then info = '不在群组中'
          when RongIMClient.SendErrorStatus.NOT_IN_CHATROOM       then info = '不在聊天室中'
          else
            info = errorCode
            break
        UXin.Services.noticeService.flashWarn("发送失败: #{info}")
        return

  addMessages: (message) ->
    console.log 'addMessages'
    @$el.find('#msg-box').append @message_template(
      direction: if message.getMessageDirection() == RongIMClient.MessageDirection.RECEIVE then "other_user" else "self"
      avatar: if message.getMessageDirection() == RongIMClient.MessageDirection.SEND then "owner" else "personPhoto"
      content: message.getContent()
      messageId: message.getMessageId()
      errorAavatar: "http://ssobu-dev.b0.upaiyun.com/asset_img/avatar/c77c276c3c0182f62e516b2479a14b08.gif"
    )

  getMessages: (again) ->
    console.log 'getMessages'
    conversationType = RongIMClient.ConversationType.PRIVATE.valueOf()
    @messageCache["#{conversationType}_#{UXin.currentConversationTargetId}"] ?= []
    @currentHistoryMessages = @messageCache["#{conversationType}_#{UXin.currentConversationTargetId}"]
    if @currentHistoryMessages.length is 0 && !again
      UXin.Services.noticeService.note("获取历史消息...")
      RongIMClient.getInstance().getHistoryMessages RongIMClient.ConversationType.setValue(conversationType), UXin.currentConversationTargetId, 20,
        onSuccess: (has, list) =>
          console.log("是否有剩余消息：" + has)
          @messageCache["#{conversationType}_#{UXin.currentConversationTargetId}"] = list
          UXin.Services.noticeService.flashNote("获取历史消息成功")
          @getMessages(true)
        onError: ->
          UXin.Services.noticeService.flashWarn("获取历史消息失败")
          @getMessages(true)
      return

    console.log 'render history messages'
    _.each @currentHistoryMessages, @addMessages, @

    if @getCurrentConversation()?
      @currentConversation.setUnreadMessageCount(0)
    RongIMClient.getInstance().clearMessagesUnreadStatus(RongIMClient.ConversationType.setValue(conversationType), UXin.currentConversationTargetId)
    UXin.Services.noticeService.renderUnread()
