jQuery ($) ->
  urlPrefix = () ->
    return $('.advertisements_content').attr('content')

  $(document).on 'click','.show-add-banner', ->
    bsize = $(this).closest('.setting-list').find('.setting-banner-box').size()
    if(bsize < 5 )
      $('#add-banner').modal('show')
    else
      alert('最多只能添加5张')
  $(document).on 'change', '.banner-sequence' , ->
    $this = $(this)
    this.value = this.value.replace(/[^\d]/g, '')

  $.fn.onlyNum = () ->
    $(this).keypress (event) ->
      eventObj = event || e
      keyCode = eventObj.keyCode || eventObj.which
      if (keyCode >= 48 && keyCode <= 57)
        return true
      else
        return false
  $(".banner-sequence").onlyNum()

  $(document).on 'change', '.select-adv-type', ->
    console.log 'change', '.select-adv-type'
    $this = $(this)
    if $this.val() == 'product'
      $.ajax
        url:  "#{urlPrefix()}/get_advertisement_items"
        type: 'GET'
        data: {type: 'product'}
        success: (res) ->
          $(".js-select2.select-adv-item").select2({
            data: res['products'],
            # maximumSelectionSize: 1,
            placeholder: "请输入名称"
          })
        error: (data, status, e) ->
          console.log 'error', data, status, e
          alert("操作错误")

    else if $this.val() == 'category'
      $.ajax
        url:  "#{urlPrefix()}/get_advertisement_items"
        type: 'GET'
        data: {type: 'category'}
        success: (res) ->
          console.log 'success',res
          $(".js-select2.select-adv-item").select2({
            data: res['categories'],
            # maximumSelectionSize: 1,
            placeholder: "请输入名称"
          })
        error: (data, status, e) ->
          console.log 'error', data, status, e
          alert("操作错误")
    else
      $(".js-select2.select-adv-item").select2({data: {}})

  $(document).on 'click', '.setting-banner-box .close', ->
    $this = $(this)
    $.ajax
      url:  "#{urlPrefix()}/remove_advertisement_item"
      type: 'GET'
      data: {resource_id: $this.attr('data-id')}


  $(document).on 'click', '.setting-category-box .close', ->
    $this = $(this)
    $.ajax
      url:  "/admin/stores/remove_category_item"
      type: 'GET'
      data: {id: $this.attr('data-id')}


  $(document).on 'change',  '.js-select2.select-category-item', (e)->
    $this = $(this)
    console.log 'val' , $(this).val() == ''
    resource_id = $(this).val()
    if resource_id == ''
      $('#adding_category_window .upyun_file_json').attr('data-to',"")
      $this.closest('.text-center img').attr('src', "/assets/admin/no-img-400x400.png")
    else
      $.ajax
        url:  "/admin/stores/get_category_img"
        type: 'GET'
        data: {resource_id:  resource_id}
        success: (res) ->
          console.log "res", res
          $this.parent().parent().parent().find('.text-center img').attr('src', "#{res['image_url']}")
          $this.parent().parent().parent().find('#category_avatar').val("#{res['avatar_identifier']}")
        error: (data, status, e) ->
          alert("操作错误")


  upyunPolicy = $("meta[name='upyun-policy']").attr("content")
  upyunSignature = $("meta[name='upyun-signature']").attr("content")
  upyunUrl = $("meta[name='upyun-form-url']").attr("content")
  upyunBucketDomain = $("meta[name='upyun-domain']").attr("content")

  $(document).on 'click',"input.category_upyun_file_json", ->
    $(this).fileupload
      paramName: "file"
      url: upyunUrl
      forceIframeTransport: true
      formData:
        "policy": upyunPolicy
        "signature": upyunSignature
      add: (e, data) ->
        updateFileJson(e,data,upyunBucketDomain)

  updateFileJson = (e,data,upyun_bucket_domain) ->
    $this = $(e.target)
    ajax_to = $this.attr('data-to')
    button = $this.closest('.fileinput-button')
    fileName = data.originalFiles[0].name
    unless button.hasClass('uploading')

      $this.hide()
      button.addClass('uploading')
      data.submit().done (doc) ->
        returnUrl = doc[0].location.href
        queryString = returnUrl.split("?")[1]
        qs = $.parseQueryString(queryString)
        if qs.code isnt "200"
          button.removeClass('uploading')
          $this.show()
          alert('图片上传失败')
        else
          [_, ..., fileName] = qs.url.split '/'
          button.find('.imgsize.img-200-200').attr('style', "background-image:url(#{ upyunBucketDomain }/#{ qs.url })")
          button.removeClass('uploading')
          $this.show()
          $.ajax
            url:  ajax_to
            type: 'POST'
            data: {avatar: fileName}
            success: (res) ->
              $("#product-category-list-#{res['id']}").attr('style', "background-image:url(#{ upyunBucketDomain }/#{ qs.url })")
              alert(res['message'])
            error: (data, status, e) ->
              console.log 'data, status, e', data, status, e
              alert("操作错误")

  $(document).on 'click', '.new_store #store_submit', ->
    checkbox = document.getElementById('agree');
    if checkbox.checked == true
      $('.new_store form')[0].submit()
    else
      alert("请先阅读并同意《UBOSS商家入驻协议》")
