$ ->
  $('.emoticon-box .emoticon').on 'click',->
    if($(this).hasClass('active')!= true)
      $('.emoticon-box .emoticon').removeClass('active')
      $(this).addClass('active')
      star_num=$(this).attr('data-star')
      $('.star-box').empty()
      for i in [star_num..1]
        $('.star-box').append('<div class="star"></div>')
