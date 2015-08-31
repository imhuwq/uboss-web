$ ->
  $('.city-select#province').on 'change', ->
    province = $('.city-select#province').val()
    $.ajax
      url: '/account/user_addresses/update_select',
      type: 'GET',
      data: {province: province}
  $('.city-select#city').on 'change', ->
    city = $('.city-select#city').val()
    $.ajax
      url: '/account/user_addresses/update_select',
      type: 'GET',
      data: {city: city}
