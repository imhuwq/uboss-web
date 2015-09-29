$(document).on 'nested:fieldAdded', (event) ->
  $(".js-select2-privacy-tags").select2({})

$(document).on 'ready page:load', ->
  $(".js-select2-privacy-tags").select2({})
