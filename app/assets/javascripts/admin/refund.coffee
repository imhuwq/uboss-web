jQuery ($) ->
  $(document).on 'click','.image-box .close', ->
    formGroup = $(this).closest(".form-group")
    hiddenFile = formGroup.find('input.file[type=hidden]')
    $(this).closest('.image-box').remove()
    fvalues =''
    hiddenFile.val(fvalues)
    formGroup.find('.image-box').each (index)->   
      if !$(this).hasClass('fileinput-button')     
        [_, ..., fileName]=$(this).find('img').attr('alt').split '/' 
        console.log(formGroup.find('.image-box').length)
        if formGroup.find('.image-box').length == index+1     
          fvalues=fvalues+fileName+''
        else
          fvalues=fvalues+fileName+','
    hiddenFile.val(fvalues)
