
RongIMClient.init "mgb7ka1nb9jng"

UXin =
  ConversationList: []
  UserList: {}
  currentConversationTargetId: null

window.UXin = UXin

initConversationList = ->
  $('#conversation-list').html('')
  for item in UXin.ConversationList
    targetUserId = item.getTargetId()
    targetUser = UXin.UserList[targetUserId]
    targetUserAvatar = if targetUser? then targetUser.getPortraitUri() else 'http://ssobu-dev.b0.upaiyun.com/asset_img/avatar/c77c276c3c0182f62e516b2479a14b08.gif'
    hideMsgNum = if item.getUnreadMessageCount() == 0 then "hidden" else ""
    html = """
      <li targetType="#{item.getConversationType().valueOf()}" targetId="#{item.getTargetId()}" targetName="#{item.getConversationTitle()}">
        <span class="user_img">
          <img src='#{targetUserAvatar}'/>
          <font class="conversation_msg_num #{hideMsgNum}">#{item.getUnreadMessageCount()}</font>
        </span>
        <span class="conversationInfo">
          <font class="user_name">#{item.getConversationTitle()}</font>
          <font class="date" >#{new Date(+item.getLatestTime()).toString().split(" ")[4]}</font>
        </span>
      </li>
    """
    htmlEle = $(html)
    if targetUser?
      htmlEle.find('.user_img img').attr('src', targetUser.getPortraitUri())
    else
      RongIMClient.getInstance().getUserInfo targetUserId,
        onSuccess: (info) ->
          console.log "Get user info #{targetUserId}"
          UXin.UserList[targetUserId] = info
          htmlEle.find('.user_img img').attr('src', info.getPortraitUri())
        onError: ->
          console.log 'Get user info error'
    htmlEle.appendTo('#conversation-list')

$.getJSON '/chat/token', (data) ->
  token = data.token
  RongIMClient.connect token,
    onSuccess: (userId) ->
      console.log("Login successfully." + userId)
      RongIMClient.getInstance().syncConversationList
        onSuccess: ->
          setTimeout ->
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
            initConversationList()
          , 1000
        onError: ->
          UXin.ConversationList = RongIMClient.getInstance().getConversationList()
    onError: (errorCode) ->
      info = ''
      switch errorCode
        when RongIMClient.callback.ErrorCode.TIMEOUT                       then info = '超时'
        when RongIMClient.callback.ErrorCode.UNKNOWN_ERROR                 then info = '未知错误'
        when RongIMClient.ConnectErrorStatus.UNACCEPTABLE_PROTOCOL_VERSION then info = '不可接受的协议版本'
        when RongIMClient.ConnectErrorStatus.IDENTIFIER_REJECTED           then info = 'appkey不正确'
        when RongIMClient.ConnectErrorStatus.SERVER_UNAVAILABLE            then info = '服务器不可用'
        when RongIMClient.ConnectErrorStatus.TOKEN_INCORRECT               then info = 'token无效'
        when RongIMClient.ConnectErrorStatus.NOT_AUTHORIZED                then info = '未认证'
        when RongIMClient.ConnectErrorStatus.REDIRECT                      then info = '重新获取导航'
        when RongIMClient.ConnectErrorStatus.PACKAGE_ERROR                 then info = '包名错误'
        when RongIMClient.ConnectErrorStatus.APP_BLOCK_OR_DELETE           then info = '应用已被封禁或已被删除'
        when RongIMClient.ConnectErrorStatus.BLOCK                         then info = '用户被封禁'
        when RongIMClient.ConnectErrorStatus.TOKEN_EXPIRE                  then info = 'token已过期'
        when RongIMClient.ConnectErrorStatus.DEVICE_ERROR                  then info = '设备号错误'
      console.log("失败:" + info)

  RongIMClient.setConnectionStatusListener onChanged: (status) ->
    switch status
      when RongIMClient.ConnectionStatus.CONNECTED          then console.log '链接成功'
      when RongIMClient.ConnectionStatus.CONNECTING         then console.log '正在链接'
      when RongIMClient.ConnectionStatus.RECONNECT          then console.log '重新链接'
      when RongIMClient.ConnectionStatus.OTHER_DEVICE_LOGIN then console.log '他设备登'
      when RongIMClient.ConnectionStatus.CLOSURE            then console.log '连接关闭'
      when RongIMClient.ConnectionStatus.UNKNOWN_ERROR      then console.log '未知错误'
      when RongIMClient.ConnectionStatus.LOGOUT             then console.log '登出'
      when RongIMClient.ConnectionStatus.BLOCK              then console.log '用户已被封禁'
    return

  RongIMClient.getInstance().setOnReceiveMessageListener
    onReceived: (message) ->

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
        when RongIMClient.MessageType.TextMessage
          $('#msg-list').append("<p>#{message.getContent()}</p>")
          initConversationList()
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

$(document).on 'click', '#send-message', ->
  msg = new (RongIMClient.TextMessage)
  tMsg = $('#sendMsg').val()
  unless !!tMsg
    console.log('need msg')
    return false
  msg.setContent tMsg
  #或者使用RongIMClient.TextMessage.obtain方法.具体使用请参见文档
  #msg = RongIMClient.TextMessage.obtain('hello')
  conversationtype = RongIMClient.ConversationType.PRIVATE
  if RongIMClient.getInstance().getConversation(RongIMClient.ConversationType.setValue(conversationtype.valueOf()), UXin.currentConversationTargetId) is null
    RongIMClient.getInstance().createConversation(RongIMClient.ConversationType.setValue(conversationtype.valueOf()), UXin.currentConversationTargetId, '新会话')

  targetId = $('#targetId').val()
  unless !!targetId
    targetId = '44'
  console.log targetId
  RongIMClient.getInstance().sendMessage conversationtype, targetId, msg, null,
    onSuccess: ->
      console.log 'Send successfully'
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
      console.log '发送失败:' + info
      return
  initConversationList()

$(document).on 'click', '#conversation-list li', ->
  element = $(this)
  UXin.currentConversationTargetId = element.attr('targetId')
  $("#targetId").val(UXin.currentConversationTargetId)
