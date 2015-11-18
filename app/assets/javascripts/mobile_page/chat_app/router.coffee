class UXin.Router extends Backbone.Router

  routes:
    'conversations/:id': 'openConversation'
    'conversations': 'openChat'
    '*path': 'openChat'

  openChat: ->
    console.log "openChat"
    UXin.Views.chat ?= new UXin.Views.Chat
    if UXin.Views.chat.hasSync
      $('#chat-box').html UXin.Views.chat.el
      @renderChatNav()
    else
      UXin.currentConversationTargetId = null
      @listenToOnce UXin.Views.chat, 'syncdone', =>
        $('#chat-box').html UXin.Views.chat.el unless UXin.currentConversationTargetId?
        @renderChatNav()

  openConversation: (targetId) ->
    console.log "openConversation:#{targetId}"
    UXin.currentConversationTargetId = targetId
    UXin.Views.conversation ?= new UXin.Views.Conversation
    $('#chat-box').html UXin.Views.conversation.el
    @renderConversationNav()

  renderConversationNav: ->
    $('header .back').text('返回').attr('href', '#')

  renderChatNav: ->
    $('header .back').text('主页').attr('href', '/')
