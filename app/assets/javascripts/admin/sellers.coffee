$ ->

  $(document).on 'click', '.edit-rate-btn', (e) ->
    e.preventDefault()
    platform_rate = $(this).find('input[name=platform_service_rate]').val()
    agent_rate = $(this).find('input[name=agent_service_rate]').val()
    form = $("#service-rate-modal form")
    form.find('.platform-rate').val(platform_rate)
    form.find('.agent-rate').val(agent_rate)
    form.attr('action', $(this).attr("href"))
    $("#service-rate-modal").modal("show")
