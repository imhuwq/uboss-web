$(document).on 'ready page:change', ->
  clock_interview = $('#clock_refund')
  clock_interview.countdown clock_interview.data('endtime')
  .on 'update.countdown', (event)->
    $(this).html(event.strftime('' + '<span class=\'unit-container\'><span>%d</span></span> 天 ' \
         + '<span class=\'unit-container\'><span>%H</span></span> 时 ' \
         + '<span class=\'unit-container\'><span>%M</span></span> 分 ' \
         + '<span class=\'unit-container\'><span>%S</span></span> 秒'))
  .on 'finish.countdown', (event)->
    $(this).html(event.strftime('' + '<span class=\'unit-container\'><span>%d</span></span> 天 ' \
         + '<span class=\'unit-container\'><span>%H</span></span> 时 ' \
         + '<span class=\'unit-container\'><span>%M</span></span> 分 ' \
         + '<span class=\'unit-container\'><span>%S</span></span> 秒'))
