$(document).on 'nested:fieldAdded', (event) ->
  $('.add_different_area').find('.fields').last().find('.js-select2-privacy-tags').select2({});

$(document).on 'ready page:load', ->
  $(".js-select2-privacy-tags").select2({})
