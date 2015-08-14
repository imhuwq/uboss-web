#= require jquery2
#= require wow
#= require_self

$ ->
  new WOW().init()
  #屏幕适配
  if $(document).width() < 1338
    if $(document).width()< 1035
      $('.img').addClass('img_mini')
    else
      $('.img').addClass('img_min')
    $('.page4_cont_list').addClass('page4_cont_list_min')
    # 视频适配
    $("#video").addClass('video_min')
    $('iframe').attr('src',"http://v.qq.com/iframe/player.html?vid=o0161da2c7v&amp;width=600&amp;height=450&amp;auto=0")
      .attr('width','600')
      .attr('height','450')
  else
    $('.img').addClass('img_max')
    $('.page4_cont_list').addClass('page4_cont_list_max')
    #视频适配
    $('#video').addClass('video_max')
    $('iframe').attr('src',"http://v.qq.com/iframe/player.html?vid=o0161da2c7v&amp;width=800&amp;height=600&amp;auto=0")
      .attr('width','800')
      .attr('height','600')
