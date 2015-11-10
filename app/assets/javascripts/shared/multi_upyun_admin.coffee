$ ->
  upyunPolicy = $("meta[name='upyun-policy']").attr("content")
  upyunSignature = $("meta[name='upyun-signature']").attr("content")
  upyunUrl = $("meta[name='upyun-form-url']").attr("content")
  upyunBucketDomain = $("meta[name='upyun-domain']").attr("content")

  $("input.multi_upyun_file").click ->
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
    formGroup = $this.closest(".form-group")
    if formGroup.find('input.file[type=hidden]').val().split(',').length >= 3
      alert('最多只能上传三张图片')
      return
    button = $this.closest('.fileinput-button')
    buttonTxt = button.children('span')
    form = $this.closest("form")
    form.data("waiting-upload", true)
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

          values = hiddenFile.val().split(',')
          values = values.filter(String)
          values.push(fileName)
          hiddenFile.val(values.join(','))

          img = $('<img>')
          img.attr('src', "#{ upyunBucketDomain }/#{ qs.url }-w320")
          img.appendTo('#imagediv')

          $(formGroup.find('.fileinput-button img')[0]).after(img)
          form.data("waiting-upload", false)

          button.removeClass('uploading')
          $this.show()
