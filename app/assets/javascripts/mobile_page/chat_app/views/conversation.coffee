class UXin.Views.Conversation extends Backbone.View

  template: JST["#{UXin.TemplatesPath}/conversation"]
  message_template: JST["#{UXin.TemplatesPath}/message"]

  className: 'conversation-box'

  events:
    'click #send-msg-btn': 'sendMessage'

  initialize: ->
    @render()

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
        @addHistoryMessages(content.getMessage())
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

  addHistoryMessages: (message) ->
    console.log 'addHistoryMessages'
    @$el.find('#msg-box').append @message_template(
      direction: if message.getMessageDirection() == RongIMClient.MessageDirection.RECEIVE then "other_user" else "self"
      avatar: if message.getMessageDirection() == RongIMClient.MessageDirection.SEND then "owner" else "personPhoto"
      content: message.getContent()
      messageId: message.getMessageId()
    )

  render: ->
    @$el.html @template()
    @
