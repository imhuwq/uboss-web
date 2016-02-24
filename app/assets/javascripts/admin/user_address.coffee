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
    request_path = $('#request_path').val()
    $.ajax
      url: "/admin/user_addresses/#{address_id}/change_default_address",
      type: 'GET',
      data: {
        title: title
        request_path: $('#request_path').val()
      },
    .done (data) ->
      console.log data
      $('#address-list-box').slideUp();
      $('html').removeClass('lock');
      $('#default_get_address').html(data['default_get_address'])
      $('#default_post_address').html(data['default_post_address'])
    .fail (xhr, textStatus) ->
      if xhr.responseJSON?
        alert(xhr.responseJSON.message)
      else
        alert('修改失败')

$(document).on 'click', '#default_post_address', ->
  console.log "$('#user_address_usage_default_post_address').val()", $('#user_address_usage_default_post_address').val()
  console.log "$('#user_address_usage_default_post_address').val() == 'false'", $('#user_address_usage_default_post_address').val() == 'false'
  if $('#user_address_usage_default_post_address').val() == 'false'
    $(this).removeClass('btn-link')
    $('#user_address_usage_default_post_address').val('true')
  else
    $(this).addClass('btn-link')
    $('#user_address_usage_default_post_address').val('false')

$(document).on 'click', '#default_get_address', ->
  if $('#user_address_usage_default_get_address').val() == 'false'
    $(this).removeClass('btn-link')
    $('#user_address_usage_default_get_address').val('true')
  else
    $(this).addClass('btn-link')
    $('#user_address_usage_default_get_address').val('false')
