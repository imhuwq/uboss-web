class UXin.Services.ConnectionService

  constructor: ->
    @listenTo @, 'start', ->
      UXin.Services.noticeService.note('连接中...')

  currentStatus: null

  connect: ->
    @trigger('start')
    $.getJSON '/chat/token', (data) =>
      RongIMClient.connect data.token, @getIMConnectionCallBack()

  processStatus: (status) =>
    info = error = ""
    @currentStatus = status
    switch status
      when RongIMClient.ConnectionStatus.CONNECTED
        info = '链接成功'
        @trigger('success')
      when RongIMClient.ConnectionStatus.CONNECTING         then info = '正在链接'
      when RongIMClient.ConnectionStatus.RECONNECT          then info = '重新链接'
      when RongIMClient.ConnectionStatus.OTHER_DEVICE_LOGIN then error = '其他设备登陆'
      when RongIMClient.ConnectionStatus.CLOSURE            then error = '连接关闭'
      when RongIMClient.ConnectionStatus.UNKNOWN_ERROR      then error = '未知错误'
      when RongIMClient.ConnectionStatus.LOGOUT             then error = '登出'
      when RongIMClient.ConnectionStatus.BLOCK              then error = '用户已被封禁'
    if !!error
      @trigger('fail')
      UXin.Services.noticeService.warn error
    else
      UXin.Services.noticeService.flashNote info

  getIMConnectionCallBack: ->
    if @iMConnectionCallBack? then @iMConnectionCallBack else new RongIMClient.callback(@processIMSuccess, @processIMFail)

  processIMSuccess: (userId) =>
    console.log "login success: #{userId}"

  processIMFail: (errorCode) =>
    @trigger('fail')
    info = error = ''
    switch errorCode
      when RongIMClient.callback.ErrorCode.TIMEOUT                       then info = '超时'
      when RongIMClient.callback.ErrorCode.UNKNOWN_ERROR                 then info = '未知错误'
      when RongIMClient.ConnectErrorStatus.UNACCEPTABLE_PROTOCOL_VERSION then info = '不可接受的协议版本'
      when RongIMClient.ConnectErrorStatus.IDENTIFIER_REJECTED           then info = '参数不正确'
      when RongIMClient.ConnectErrorStatus.SERVER_UNAVAILABLE            then info = '服务器不可用'
      when RongIMClient.ConnectErrorStatus.TOKEN_INCORRECT               then info = '链接无效'
      when RongIMClient.ConnectErrorStatus.NOT_AUTHORIZED                then info = '未认证'
      when RongIMClient.ConnectErrorStatus.REDIRECT                      then info = '重新获取导航'
      when RongIMClient.ConnectErrorStatus.PACKAGE_ERROR                 then info = '包名错误'
      when RongIMClient.ConnectErrorStatus.APP_BLOCK_OR_DELETE           then info = '已被封禁或已被删除'
      when RongIMClient.ConnectErrorStatus.BLOCK                         then info = '被封禁'
      when RongIMClient.ConnectErrorStatus.TOKEN_EXPIRE                  then info = '会话已过期'
      when RongIMClient.ConnectErrorStatus.DEVICE_ERROR                  then info = '设备初始错误'
    UXin.Services.noticeService.warn error

_.extend(UXin.Services.ConnectionService.prototype, Backbone.Events)
