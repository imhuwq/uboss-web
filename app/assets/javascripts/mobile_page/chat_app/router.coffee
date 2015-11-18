class UXin.Router extends Backbone.Router

  routes:
    'conversations/:id': 'openConversation'
    'conversations': 'openChat'
    '*path': 'openChat'

  openChat: ->
    new UXin.Views.Chat

  openConversation: (targetId) ->
    console.log "openConversation:#{targetId}"
