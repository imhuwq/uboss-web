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
    fieldName = $this.prop("name")
    unless button.hasClass('uploading')

      $this.hide()
      button.addClass('uploading')
      data.submit().done (doc) ->
        returnUrl = doc[0].location.href
        queryString = returnUrl.split("?")[1]
        qs = $.parseQueryString(queryString)
        if qs.code isnt "200"
          buttonTxt.text('选择图片')
          button.removeClass('uploading')
          $this.show()
          alert('图片上传失败')
        else
          hiddenFile = formGroup.find('input.file[type=hidden]')
          [_, ..., fileName] = qs.url.split '/'
          hiddenFile.val(fileName)
          formGroup.find('.fileinput-button img').attr('src', "#{ upyunBucketDomain }/#{ qs.url }-w320")
          form.data("waiting-upload", false)

          button.removeClass('uploading')
          $this.show()

  $("input.upyun_file_json").click ->
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
    form = $this.closest("form")
    formGroup = $this.closest(".form-group")
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
          formGroup.find('.fileinput-button img').attr('src', "#{ upyunBucketDomain }/#{ qs.url }-w320")
          form.data("waiting-upload", false)
          button.removeClass('uploading')
          $this.show()
          console.log " $.ajax"
          $.ajax
            url:  ajax_to
            type: 'POST'
            data: {avatar: fileName}
            success: (res) ->
              console.log "res", res
              alert(res['message'])
            error: (data, status, e) ->
              alert("操作错误")

