class UXin.Router extends Backbone.Router

  routes:
    'conversations/:id': 'openConversation'
    'conversations': 'openChat'
    '*path': 'openChat'

  openChat: ->
    console.log "openChat"
    @clearCurrentConversation()
    UXin.Views.chat ?= new UXin.Views.Chat
    if UXin.Views.chat.hasSync
      $('#chat-box').html UXin.Views.chat.render().el
      @renderChatNav()
    else
      $('#chat-box').html ""
      UXin.currentConversationTargetId = null
      @listenToOnce UXin.Views.chat, 'syncdone', =>
        $('#chat-box').html UXin.Views.chat.el unless UXin.currentConversationTargetId?
        @renderChatNav()

  openConversation: (targetId) ->
    console.log "openConversation:#{targetId}"
    UXin.currentConversationTargetId = targetId
    UXin.Views.conversation ?= new UXin.Views.Conversation
    $('#chat-box').html UXin.Views.conversation.render().el
    @renderConversationNav()

  renderConversationNav: ->
    $('header .back').html("返回").attr('href', '#')

  renderChatNav: ->
    $('header .back').html("主页").attr('href', '/')

  clearCurrentConversation: ->
    UXin.Views.conversation.clearCurrentConversation() if UXin.Views.conversation?
