$('.add_attribute_class').on 'click',() ->
  y_po = $(this).position().top
  x_po = $(this).position().left
  console.log(x_po)
  console.log(y_po)
  style = "top:#{ y_po }px;left:#{x_po}px;"
  attribute_class = $(this).prevAll('select').first().val()
  console.log(attribute_class)
  console.log(style)
  $('.popover').attr('style',style)
  $('.popover').show()

$('.js-btn-cancel').on 'click',() ->
  $('.popover').fadeOut()
