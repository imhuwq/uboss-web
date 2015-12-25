$(document).on 'click','#category-checkbox' , ->
  console.log($(this).prop('checked'))
  if $(this).prop('checked') == 'true'
    $(this).closest(".list-table").find(".checkbox").prop('disabled','false')
    $(this).closest(".list-table").find(".form-item-check").val("false")
  else
    $(this).closest(".list-table").find(".checkbox").prop('checked',this.checked)
    $(this).closest(".list-table").find(".form-item-check").val("true")

