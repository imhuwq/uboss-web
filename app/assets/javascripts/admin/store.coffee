$(document).on 'change',  '#adding_category_window #category_tages', (e)->
	console.log 'val' , $(this).val() == ''
	resource_id = $(this).val()
	if resource_id == ''
		$('#add_category_img').addClass('hidden')
		$('#adding_category_window .upyun_file_json').attr('data-to',"")
	else
		$.ajax
		  url:  "/admin/categories/#{resource_id}/change_category_img"
		  type: 'GET'
		  data: {resource_id:  resource_id}
		  success: (res) ->
		    console.log "res", res
		    $('#add_category_img').removeClass('hidden')
		    $('#add_category_img img').attr('src', "#{res['url']}-w320")
		    $('#adding_category_window .upyun_file_json').attr('data-to',"/admin/categories/update_category_img?resource_id=#{resource_id}")
		  error: (data, status, e) ->
		    alert("操作错误")

$(document).on 'change',  '#adding_product_window #category_tages', (e)->
	$this = $(this)
	resource_id = $(this).val()
	if resource_id == ''
		$('#show_product_advertisement_img').addClass('hidden')
		$('#add_to_advertisement').addClass('hidden')
		$('#adding_product_window .upyun_file_json').attr('data-to',"")
	else
		$.ajax
		  url:  "/admin/stores/#{resource_id}/show_product_advertisement_img"
		  type: 'GET'
		  data: {resource_id:  resource_id}
		  success: (res) ->
		    $('#show_product_advertisement_img').removeClass('hidden')
		    $('#add_to_advertisement').removeClass('hidden')
		    $('#show_product_advertisement_img img').attr('src', "#{res['url']}-w320")
		    $('#adding_product_window .upyun_file_json').attr('data-id',resource_id)
		    $('#adding_product_window .upyun_file_json').attr('data-to',"/admin/stores/update_product_advertisement_img?resource_id=#{resource_id}")
		    if res['show_advertisement'] == true
		    	$('#adding_product_window #add_to_advertisement').removeClass('btn-link')
		    	$('#adding_product_window #add_to_advertisement').html('移出店铺广告')
		    else
		    	$('#adding_product_window #add_to_advertisement').addClass('btn-link')
		    	$('#adding_product_window #add_to_advertisement').html('加入店铺广告')
		  error: (data, status, e) ->
		    alert("操作错误")

$(document).on 'click','#adding_product_window #add_to_advertisement', (e)->
	resource_id = $('#adding_product_window .upyun_file_json').attr('data-id')
	$.ajax
		url:  "/admin/stores/#{resource_id}/add_to_advertisement"
		type: 'POST'
		data: {resource_id:  resource_id}
		success: (res) ->
			if res['show_advertisement'] == true
				$('#adding_product_window #add_to_advertisement').removeClass('btn-link')
				$('#adding_product_window #add_to_advertisement').html('移出店铺广告')
			else
				$('#adding_product_window #add_to_advertisement').addClass('btn-link')
				$('#adding_product_window #add_to_advertisement').html('加入店铺广告')
		error: (data, status, e) ->
			alert("操作错误")



$(document).on 'change', '#store_name', ->
	$this = $(this)
	resource_id = $this.attr('data-id')
	store_name = $this.val()

	$.ajax
		url:  "/admin/stores/#{resource_id}/update_store_name"
		type: 'POST'
		data: {store_name:  store_name}
		success: (res) ->
			console.log "res", res
		error: (data, status, e) ->
			console.log data, status, e
			alert("操作错误")


$(document).on 'change', '#store_short_description', ->
	$this = $(this)
	resource_id = $this.attr('data-id')
	store_short_description = $this.val()

	$.ajax
		url:  "/admin/stores/#{resource_id}/update_store_short_description"
		type: 'POST'
		data: {store_short_description:  store_short_description}
		success: (res) ->
			console.log "res", res
		error: (data, status, e) ->
			console.log data, status, e
			alert("操作错误")

