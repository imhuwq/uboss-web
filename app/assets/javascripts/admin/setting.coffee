jQuery ($) ->
  $(document).on 'click','.show-add-banner', ->
    bsize = $(this).closest('.setting-list').find('.setting-banner-box').size()
    if(bsize <= 5 )
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
  
  $(document).on 'click','.setting-banner-box .close', ->
    $(this).closest('.setting-banner-box').remove()
  
  $(document).on 'click','.setting-category-box .close', ->
    $(this).closest('.setting-category-box').remove()
