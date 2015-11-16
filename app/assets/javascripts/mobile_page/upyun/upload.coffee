$ ->
  upyunPolicy = $("meta[name='upyun-policy']").attr("content")
  upyunSignature = $("meta[name='upyun-signature']").attr("content")
  upyunUrl = $("meta[name='upyun-form-url']").attr("content")
  upyunBucketDomain = $("meta[name='upyun-domain']").attr("content")

  $('#uploadfile').click (e)->
    e.preventDefault()
    console.log 'go'
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
          $('body').append "<img src='#{upyunBucketDomain}/#{response.url}-thumb'></img>"
        else
          alert('上传失败')
