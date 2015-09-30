$ ->

  $(document).on 'ajaxSuccess', '.like-product-btn', (event, xhr, settings, data) ->
    flash_content = $('<div class="pop-alert flash_css"><div class="pop-content"></div>')
    flash_content.appendTo('body')
    if data.favoured
      $(this).addClass('active')
      flash_content.find('.pop-content').append '''
        <div class="pop-text">您喜欢了该商品，可以在店铺主页<br/>我的喜欢模块找到本商品</div>
      '''
    else
      $(this).removeClass('active')
      flash_content.find('.pop-content').append '''
        <div class="pop-text line-2 gray">您取消了该喜欢商品</div>
      '''
    setTimeout ->
      flash_content.remove()
    , 3000

  $(document).on 'ajaxError', '.like-product-btn', () ->
    alert "操作失败"
