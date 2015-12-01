$(document).on 'nested:fieldAdded', (event) ->
  $('.add_different_area').find('.fields').last().find('.js-select2-privacy-tags').select2({});

$(document).on 'ready page:load', ->
  $(".js-select2-privacy-tags").select2({})

$(document).on 'click', '.category-checkbox' ,(e) ->
  e.preventDefault()
  $this = $(this)
  console.log "this", this
  console.log "$this.hasClass('checked')", $this.hasClass("checked")
  console.log "$this.closest('.list-table')", $this.closest(".list-table")
  if $this.attr('checked') == 'true'
    $this.closest(".list-table").find(".checkbox").attr('checked','false')
    $this.closest(".list-table").find(".form-item-check").val("false")
  else
    console.log "checked"
    $this.closest(".list-table").find(".checkbox").attr('checked','true')
    $this.closest(".list-table").find(".form-item-check").val("true")

