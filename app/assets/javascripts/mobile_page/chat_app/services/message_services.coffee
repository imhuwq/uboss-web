class UXin.Services.MessageServices

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
      when RongIMClient.MessageType.TextMessage                    then console.log 'image message_receive'
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
    return

_.extend(UXin.Services.MessageServices.prototype, Backbone.Events)
