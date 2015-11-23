#= require underscore-min
#= require backbone-min
#= require_self
#= require_tree ./templates
#= require_tree ./views
#= require_tree ./services
#= require ./router

((root) ->

  # disable backbone sync
  Backbone.sync = ->
    return false

  UXin =
    TemplatesPath: 'mobile_page/chat_app/templates'
    Data:
      messageCache: {}
    Views: {}
    Models: {}
    Collections: {}
    Router: null
    Services: {}
    currentConversationTargetId: null
    totalUnreadCount: 0

  UXin.init = ->
    RongIMClient.init "mgb7ka1nb9jng"

    UXin.Services.connectionService = new UXin.Services.ConnectionService
    UXin.Services.messageServices   = new UXin.Services.MessageServices
    UXin.Services.noticeService     = new UXin.Services.NoticeService

    RongIMClient.getInstance().setOnReceiveMessageListener
      onReceived: (message) ->
        UXin.Services.messageServices.processReceive message

    RongIMClient.setConnectionStatusListener onChanged: (status) ->
      UXin.Services.connectionService.processStatus(status)

    UXin.Services.connectionService.connect()

  root.UXin = UXin

)(window)
