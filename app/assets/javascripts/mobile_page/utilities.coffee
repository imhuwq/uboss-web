$ ->

  $('.share-wx-btn').on 'click', (e)->
    e.preventDefault()
    $(".wx-mod-pop").show()

  $(".wx-mod-pop").on 'click', ->
    $(this).hide()

  flash = $(".flash_css")
  setTimeout ->
    flash.fadeOut ->
      $(this).remove()
  , 5000

  $(".alert").on "click", ->
    $(this).closest('.flash_css').remove()

  waypointHandler = (direction) ->
    element = $(this.element)
    if not element.hasClass('loading') and direction == 'down'
      element.addClass('loading')
      element.text('加载中...')
      params = { before_timestamp: $(element.data('ele')).last().attr('timestamp') }
      Waypoint.destroyAll()
      $.get element.data('ref'), params, (data) ->
        if $.trim(data).length
          $(element.data('container')).append(data)
          element.removeClass('loading')
          element.text('加载更多')
          $('#load-more').waypoint(waypointHandler, offset: '100%')
        else
          element.remove()

  $('#load-more').waypoint(waypointHandler, offset: '100%')
