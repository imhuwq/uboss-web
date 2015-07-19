$ ->
  flash = $(".flash_css")
  setTimeout ->
    flash.fadeOut ->
      $(this).remove()
  , 10000

  $(".alert .close").on "click", ->
    $(this).closest('.flash_css').remove()
