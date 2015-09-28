$ ->

  $('#showlist').click (e)->
    e.preventDefault()
    $(".accunt_adil").addClass('undis')
    $(".account-privilege-cards").addClass('undis')
    $(".my_con1").removeClass('undis')
    $("#showlist").addClass('active')
    $("#showincome").removeClass('active')
    $("#showpcards").removeClass('active')

  $('#showincome').click (e)->
    e.preventDefault()
    $(".my_con1").addClass('undis')
    $(".account-privilege-cards").addClass('undis')
    $(".accunt_adil").removeClass('undis')
    $("#showlist").removeClass('active')
    $("#showpcards").removeClass('active')
    $("#showincome").addClass('active')

  $('#showpcards').click (e)->
    e.preventDefault()
    $(this).closest('ul').find('a').removeClass('active')
    $(this).addClass('active')
    $(".my_con1").addClass('undis')
    $(".accunt_adil").addClass('undis')
    $(".account-privilege-cards").removeClass('undis')
