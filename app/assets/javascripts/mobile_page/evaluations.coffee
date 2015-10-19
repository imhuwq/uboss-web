$ ->
  $('.emoticon-box .emoticon').on 'click',->
    if($(this).hasClass('active')!= true)
      $('.emoticon-box .emoticon').removeClass('active')
      $(this).addClass('active')
