jQuery ($) ->
  $(document).on 'click','.address-alert', ->
    $('#address-list-box').slideDown()
    $('#address-list-box .name').html($(this).attr('title'))
    $('html').addClass('lock');
  $(document).on 'click', '#address-list-box .close', ->
    $('#address-list-box').slideUp();
    $('html').removeClass('lock');
  $(document).on 'click', '#address-list-box .check_default_address',->
    address_id = $(this).attr('id')
    title = $('#address-list-box .name').html()
    order_id = $('#order_id').val()
    $.ajax
      url: '/admin/user_addresses/change_default_address',
      type: 'GET',
      data: {
        title: title
        address_id: address_id
        order_id: order_id
      },
    .done ->
      $('#address-list-box').slideUp();
      $('html').removeClass('lock');
    .fail (xhr, textStatus) ->
      if xhr.responseJSON?
        alert(xhr.responseJSON.message)
      else
        alert('修改失败')
