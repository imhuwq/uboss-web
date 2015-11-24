class UXin.Services.NoticeService

  el: '#chat-notice'

  titleEl: '.header-bar .back'

  renderUnread: ->
    title = $(@titleEl).text()
    totalUnreadCount = RongIMClient.getInstance().getTotalUnreadCount()
    if totalUnreadCount > 0
      if $(@titleEl).find('.new-msg-notice').length > 0
        $(@titleEl).find('.new-msg-notice').html("(#{RongIMClient.getInstance().getTotalUnreadCount()})")
      else
        $(@titleEl).append """
          <small class="new-msg-notice">(#{RongIMClient.getInstance().getTotalUnreadCount()})</small>
        """
    else
      $(@titleEl).find('.new-msg-notice').html("")

  flashWarn: (msg) ->
    @warn msg
    @hideNote()

  flashNote: (msg) ->
    @note msg
    @hideNote()

  note: (msg) ->
    @clearClock()
    $(@el).removeClass('error').html(msg).show()

  warn: (msg) ->
    @clearClock()
    $(@el).addClass('error').html(msg).show()

  hideNote: (delay = true)->
    if delay
      @closeClock = setTimeout =>
        $(@el).fadeOut()
      , 1000
    else
      $(@el).fadeOut()

  clearClock: ->
    clearTimeout(@closeClock)
