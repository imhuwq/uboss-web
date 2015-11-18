$ ->
  $('.payment-box').on 'click',->
    $('.payment-box').removeClass('pay-checked')
    $(this).find('.pay-checkbox').addClass('pay-checked')
