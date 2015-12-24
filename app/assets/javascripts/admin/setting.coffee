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

  $(document).on 'change', '.select-adv-type', ->
    console.log 'change', '.select-adv-type'
    $this = $(this)
    if $this.val() == 'product'
      $.ajax
        url:  "/admin/stores/get_advertisement_items"
        type: 'GET'
        data: {type: 'product'}
        success: (res) ->
          console.log 'success',res
          console.log 'data', res['products']
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
        url:  "/admin/stores/get_advertisement_items"
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
  $(document).on 'click', '.setting-banner-box .close', ->
    $this = $(this)
    $.ajax
      url:  "/admin/stores/remove_advertisement_item"
      type: 'GET'
      data: {id: $this.attr('data-id')}
      success: (res) ->
        # if res['success']
        #   $this.parent('.setting-banner-box').remove()
        #   $("#slider_#{$this.attr('data-id')}").remove()
      error: (data, status, e) ->
        console.log 'error', data, status, e
        alert("操作错误")

