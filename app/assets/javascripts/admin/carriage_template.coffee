$(document).on 'nested:fieldAdded', (event) ->
  $('.add_different_area').find('.fields').last().find('.js-select2-privacy-tags').select2({});

$(document).on 'ready page:load', ->
  $(".js-select2-privacy-tags").select2({})

$(document).on 'click','#category-checkbox' , ->
  console.log($(this).prop('checked'))
  if $(this).prop('checked') == 'true'
    $(this).closest(".list-table").find(".checkbox").prop('disabled','false')
    $(this).closest(".list-table").find(".form-item-check").val("false")
    console.log(1)
  else
    $(this).closest(".list-table").find(".checkbox").prop('checked',this.checked)
    $(this).closest(".list-table").find(".form-item-check").val("true")
    console.log(2)

