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
  , 10000

  $(".alert").on "click", ->
    $(this).closest('.flash_css').remove()
