$(document).on 'click','#category-checkbox' , ->
  console.log($(this).prop('checked'))
  if $(this).prop('checked') == 'true'
    $(this).closest(".list-table").find(".checkbox").prop('disabled','false')
    $(this).closest(".list-table").find(".form-item-check").val("false")
  else
    $(this).closest(".list-table").find(".checkbox").prop('checked',this.checked)
    $(this).closest(".list-table").find(".form-item-check").val("true")

$(document).on 'change', '.category-name', ->
	$this = $(this)
	resource_id = $this.attr('data-id')
	category_name = $this.val()
	console.log  'resource_id', resource_id
	console.log 'category_name', category_name
	$.ajax
	  url:  "/admin/categories/#{resource_id}/update_category_name"
	  type: 'POST'
	  data: {name:  category_name}
	  success: (res) ->
	    console.log "res", res
	    alert(res['message'])
	  error: (data, status, e) ->
	    alert("操作错误")
