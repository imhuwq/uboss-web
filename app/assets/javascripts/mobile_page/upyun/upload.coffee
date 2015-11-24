$ ->
  upyunPolicy = $("meta[name='upyun-policy']").attr("content")
  upyunSignature = $("meta[name='upyun-signature']").attr("content")
  upyunUrl = $("meta[name='upyun-form-url']").attr("content")
  upyunBucketDomain = $("meta[name='upyun-domain']").attr("content")
  $(document).on 'click','.upload-image-box .close', ->
    console.log(1)
    formGroup = $(this).closest(".form-group")
    hiddenFile = formGroup.find('input.file[type=hidden]')
    $(this).closest('.upload-image-box').remove()
    fvalues =''
    hiddenFile.val(fvalues)
    formGroup.find('.upload-image-box').each (index)->
      [_, ..., fileName]=$(this).find('img').attr('alt').split '/'
      console.log(formGroup.find('.upload-image-box').length)
      if formGroup.find('.upload-image-box').length == index+1
        fvalues=fvalues+fileName+''
      else
        fvalues=fvalues+fileName+','
    hiddenFile.val(fvalues)

  $('.upyun_file').live 'change' , (e) ->
    e.preventDefault()
    $this=$(e.target)
    formGroup = $this.closest('.form-group')
    if formGroup.find('.upload-image-box').length >= 3
      return confirm('最多只能上传三张图片')
    $('#upload-box .loading').show()
    $('#upload-box input').css('z-index', '-999')
    $.ajaxFileUpload
      fileElementId: 'file'
      url: upyunUrl
      data:
        "policy": upyunPolicy
        "signature": upyunSignature
      success: (doc, status) ->
        returnURL = doc.baseURI
        response = $.parseQueryString(returnURL)
        if (response.code == '200')
          uimg="<div class='upload-image-box'>"
          uimg=uimg+"<a href='#{upyunBucketDomain}/#{response.url}' style='background-image:url(#{upyunBucketDomain}/#{response.url})'>"
          uimg=uimg+"<img src='#{upyunBucketDomain}/#{response.url}-thumb' alt='#{response.url}'></img></a>"
          uimg=uimg+"<div class='close'></div></div>"
          $('#upload-box').append(uimg)
          hiddenFile = formGroup.find('input.file[type=hidden]')
          fvalues =''
          formGroup.find('.upload-image-box').each (index)->
            [_, ..., fileName]=$(this).find('img').attr('alt').split '/'
            if formGroup.find('.upload-image-box').length == index+1
              fvalues=fvalues+fileName+''
            else
              fvalues=fvalues+fileName+','
          hiddenFile.val(fvalues)
          $('#upload-box .loading').hide()
          $('#upload-box input').css('z-index', '1')
        else
          alert('上传失败')
          $('#upload-box .loading').hide()
          $('#upload-box input').css('z-index', '1')
