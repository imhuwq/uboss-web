class UXin.Services.NoticeService

  el: '#chat-notice'

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
