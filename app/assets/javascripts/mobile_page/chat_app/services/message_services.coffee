class UXin.Services.MessageServices

  messageCache: UXin.Data.messageCache

  processReceive: (message) ->
    window.currentMsg = message
    conversation = RongIMClient.getInstance().getConversation(message.getConversationType(), message.getTargetId())
    unless !!conversation.getConversationTitle()
      if message.getConversationType() is RongIMClient.ConversationType.PRIVATE
        RongIMClient.getInstance().getUserInfo message.getTargetId(),
          onSuccess: (info) ->
            console.log "set cs title: #{info.getUserName()}"
            conversation.setConversationTitle info.getUserName()
          onError: ->
            conversation.setConversationTitle "陌生人Id：#{message.getTargetId()}"
      else
        console.log 'unknow conversation'
        conversation.setConversationTitle("该会话类型未解析: #{message.getConversationType()} #{message.getTargetId()}")
    switch message.getMessageType()
      when RongIMClient.MessageType.TextMessage                    then console.log 'text message_receive'
      when RongIMClient.MessageType.ImageMessage                   then console.log 'image message_receive'
      when RongIMClient.MessageType.VoiceMessage                   then console.log 'voice message_receive'
      when RongIMClient.MessageType.RichContentMessage             then console.log 'rich content message_receive'
      when RongIMClient.MessageType.LocationMessage                then console.log 'location message_receive'
      when RongIMClient.MessageType.DiscussionNotificationMessage  then console.log 'discusstion message_receive'
      when RongIMClient.MessageType.InformationNotificationMessage then console.log 'information message_receive'
      when RongIMClient.MessageType.ContactNotificationMessage     then console.log 'contact message_receive'
      when RongIMClient.MessageType.ProfileNotificationMessage     then console.log 'profile message_receive'
      when RongIMClient.MessageType.CommandNotificationMessage     then console.log 'command message_receive'
      when RongIMClient.MessageType.UnknownMessage                 then console.log 'unknown message_receive'
    @processNewMessage(message)

  processNewMessage: (message)->
    if (UXin.currentConversationTargetId != message.getTargetId())
      UXin.Services.noticeService.renderUnread()
    if !@messageCache[message.getConversationType().valueOf() + "_" + message.getTargetId()]
      @messageCache[message.getConversationType() + "_" + message.getTargetId()] = [message]
    else
      @messageCache[message.getConversationType().valueOf() + "_" + message.getTargetId()].push(message)
    conversationtype = RongIMClient.ConversationType.PRIVATE
    if RongIMClient.getInstance().getConversation(RongIMClient.ConversationType.setValue(conversationtype.valueOf()), message.getTargetId()) is null
      conversation = RongIMClient.getInstance().createConversation(RongIMClient.ConversationType.setValue(conversationtype.valueOf()), message.getTargetId(), '新会话')
      RongIMClient.getInstance().getUserInfo message.getTargetId(),
        onSuccess: (info) =>
          console.log "set cs title: #{info.getUserName()}"
          conversation.setConversationTitle info.getUserName()
        onError: =>
          conversation.setConversationTitle "陌生人Id：#{message.getTargetId()}"
    @trigger('new', message)

_.extend(UXin.Services.MessageServices.prototype, Backbone.Events)
