$ ->

  $('#showlist').tap ->
    $(".accunt_adil").addClass('undis')
    $(".my_con1").removeClass('undis')
    $("#showlist").addClass('active')
    $("#showincome").removeClass('active')

  $('#showincome').tap ->
    $(".my_con1").addClass('undis')
    $(".accunt_adil").removeClass('undis')
    $("#showlist").removeClass('active')
    $("#showincome").addClass('active')
