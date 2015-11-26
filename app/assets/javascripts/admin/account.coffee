$(document).on 'ready page:load', ->

  $(document).on 'click', '.account_update_password', (e) ->
    e.preventDefault()
    form = $("#update-password-modal form")
    form.attr('action', $(this).attr("href"))
    $("#update-password-modal").modal("show")
