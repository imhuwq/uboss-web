$ ->
  upyunPolicy = $("meta[name='upyun-policy']").attr("content")
  upyunSignature = $("meta[name='upyun-signature']").attr("content")
  upyunUrl = $("meta[name='upyun-form-url']").attr("content")
  upyunBucketDomain = $("meta[name='upyun-domain']").attr("content")

  $("input.upyun_file").fileupload
    paramName: "file"
    url: upyunUrl
    forceIframeTransport: true
    formData:
      "policy": upyunPolicy
      "signature": upyunSignature
    add: (e, data) ->
      updateFile(e,data,upyunBucketDomain)

  $("input.upyun_file_closest").click ->
    upyunPolicy = $(this).siblings("meta[name='upyun-policy']").attr("content")
    upyunSignature = $(this).siblings("meta[name='upyun-signature']").attr("content")
    $(this).fileupload
      paramName: "file"
      url: upyunUrl
      forceIframeTransport: true
      formData:
        "policy": upyunPolicy
        "signature": upyunSignature
      add: (e, data) ->
        updateFile(e,data,upyunBucketDomain)


  updateFile = (e,data,upyun_bucket_domain) ->
    $this = $(e.target)
    button = $this.closest('.fileinput-button')
    buttonTxt = button.children('span')
    form = $this.closest("form")
    form.data("waiting-upload", true)
    formGroup = $this.closest(".form-group")
    fileName = data.originalFiles[0].name
    console.log "fileName", fileName
    fieldName = $this.prop("name")
    console.log "button", button
    console.log "button.hasClass('uploading')", button.hasClass('uploading')
    unless button.hasClass('uploading')

      $this.hide()
      button.addClass('uploading')
      console.log "data", data
      data.submit().done (doc) ->
        console.log "data.submit()"
        returnUrl = doc[0].location.href
        console.log "returnUrl", returnUrl
        queryString = returnUrl.split("?")[1]
        qs = $.parseQueryString(queryString)
        if qs.code isnt "200"
          buttonTxt.text('选择图片')
          button.removeClass('uploading')
          $this.show()
          alert('图片上传失败')
        else
          console.log 'formGroup', formGroup
          hiddenFile = formGroup.find('input.file[type=hidden]')
          console.log 'hiddenFile', hiddenFile
          [_, ..., fileName] = qs.url.split '/'
          # hiddenFile.val(fileName)
          hiddenFile.val("#{ upyunBucketDomain }/#{ qs.url }")
          formGroup.find('.fileinput-button img').attr('src', "#{ upyunBucketDomain }/#{ qs.url }-w320")
          form.data("waiting-upload", false)

          button.removeClass('uploading')
          $this.show()

    $("input.upyun_file_closest").click ->
    upyunPolicy = $(this).siblings("meta[name='upyun-policy']").attr("content")
    upyunSignature = $(this).siblings("meta[name='upyun-signature']").attr("content")
    $(this).fileupload
      paramName: "file"
      url: upyunUrl
      forceIframeTransport: true
      formData:
        "policy": upyunPolicy
        "signature": upyunSignature
      add: (e, data) ->
        updateFile(e,data,upyunBucketDomain)

  $("input.upyun_file_json").click ->
    upyunPolicy = $(this).siblings("meta[name='upyun-policy']").attr("content")
    upyunSignature = $(this).siblings("meta[name='upyun-signature']").attr("content")
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
    resource_id = $this.attr('data[id]')
    button = $this.closest('.fileinput-button')
    buttonTxt = button.children('span')
    form = $this.closest("form")
    form.data("waiting-upload", true)
    formGroup = $this.closest(".form-group")
    fileName = data.originalFiles[0].name
    console.log "fileName", fileName
    fieldName = $this.prop("name")
    console.log "button", button
    console.log "button.hasClass('uploading')", button.hasClass('uploading')
    unless button.hasClass('uploading')

      $this.hide()
      button.addClass('uploading')
      console.log "data", data
      data.submit().done (doc) ->
        console.log "data.submit()"
        returnUrl = doc[0].location.href
        console.log "returnUrl", returnUrl
        queryString = returnUrl.split("?")[1]
        qs = $.parseQueryString(queryString)
        if qs.code isnt "200"
          buttonTxt.text('选择图片')
          button.removeClass('uploading')
          $this.show()
          alert('图片上传失败')
        else
          $.ajax
            url: '/categories/updata_categories_img'
            type: 'POST'
            data: {id: resource_id, avatar: avatar}
            success: (res) ->
              # 获取属性列表 ->>
              that.newProperties(res['skus'])
              # <<= 获取属性列表
              # 获取sku信息 ->>
              that.newSKUs(res['sku_details'])
              # <<= 获取sku信息
              that.render('','',that.submit_way,that.product_id)
            error: (data, status, e) ->
              alert("操作错误")

          console.log 'formGroup', formGroup
          hiddenFile = formGroup.find('input.file[type=hidden]')
          console.log 'hiddenFile', hiddenFile
          [_, ..., fileName] = qs.url.split '/'
          formGroup.find('.fileinput-button img').attr('src', "#{ upyunBucketDomain }/#{ qs.url }-w320")
          form.data("waiting-upload", false)

          button.removeClass('uploading')
          $this.show()

