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
    if formGroup.find('.image-box').length >= 4
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
          #hiddenFile = formGroup.find('input.file[type=hidden]')
          #[_, ..., fileName] = qs.url.split '/'

          #values = hiddenFile.val().split(',')
          #values = values.filter(String)
          #values.push(fileName)
          #hiddenFile.val(values.join(','))
          img = '<div class="image-box">'
          img = img+'<a class="pop-img" data-src="'+ "#{ upyunBucketDomain }/#{ qs.url }"+'" style="background-image:url('+"#{ upyunBucketDomain }/#{ qs.url }"+'">'
          img = img+'<img src="'+ "#{ upyunBucketDomain }/#{ qs.url }" +'" alt="'+"#{ qs.url }"+'"></a><div class="close"><i class="fa fa-times"></i></div></div>'
          $this.closest('.upload-box').append(img)

          form.data("waiting-upload", false)

          button.removeClass('uploading')
          $this.show()
          hiddenFile = formGroup.find('input.file[type=hidden]')
          fvalues =''
          formGroup.find('.image-box').each (index)->
            if !$(this).hasClass('fileinput-button')
              [_, ..., fileName]=$(this).find('img').attr('alt').split '/'
              if formGroup.find('.image-box').length == index+1
                fvalues=fvalues+fileName+''
              else
                fvalues=fvalues+fileName+','
          hiddenFile.val(fvalues)
