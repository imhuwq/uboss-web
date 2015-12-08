$(document).on 'change',  '#adding_category_window #category_tages', (e)->
	console.log 'val' , $(this).val() == ''
	resource_id = $(this).val()
	if resource_id == ''
		$('#add_category_img').addClass('hidden')
	else
		$.ajax
		  url:  "/admin/categories/#{resource_id}/change_category_img"
		  type: 'GET'
		  data: {resource_id:  resource_id}
		  success: (res) ->
		    console.log "res", res
		    $('#add_category_img').removeClass('hidden')
		    $('#add_category_img img').attr('src', "#{res['url']}-w320")
		  error: (data, status, e) ->
		    alert("操作错误")

$(document).on 'change',  '#adding_product_window #category_tages', (e)->
	console.log 'val' , $(this).val() == ''
	resource_id = $(this).val()
	if resource_id == ''
		$('#show_product_advertisement_img').addClass('hidden')
	else
		$.ajax
		  url:  "/admin/stores/#{resource_id}/show_product_advertisement_img"
		  type: 'GET'
		  data: {resource_id:  resource_id}
		  success: (res) ->
		    console.log "res", res
		    $('#show_product_advertisement_img').removeClass('hidden')
		    $('#show_product_advertisement_img img').attr('src', "#{res['url']}-w320")
		  error: (data, status, e) ->
		    alert("操作错误")

