$ ->

  current_editing_rate = null

  $(document).on 'click', '.edit-rate-btn', (e) ->
    e.preventDefault()
    current_editing_rate = $(this)
    platform_rate = $(this).find('input[name=platform_service_rate]').val()
    agent_rate = $(this).find('input[name=agent_service_rate]').val()
    form = $("#service-rate-modal form")
    form.find('.platform-rate').val(platform_rate)
    form.find('.agent-rate').val(agent_rate)
    form.attr('action', $(this).attr("href"))
    $("#service-rate-modal").modal("show")

  $(document).on 'ajax:success', '#service-rate-modal form', (e, data) ->
    current_editing_rate.find('input[name=platform_service_rate]').val(data.platform_service_rate)
    current_editing_rate.find('input[name=agent_service_rate]').val(data.agent_service_rate)
    $(".rate-info-#{data.id}").text("#{data.platform_service_rate} | #{data.agent_service_rate}")
    alert("修改成功")
    $("#service-rate-modal").modal("hide")
    form = $("#service-rate-modal form")
    form.find('.platform-rate').val('')
    form.find('.agent-rate').val('')
    form.attr('action', '#')

  $(document).on 'ajax:error', '#service-rate-modal form', (e, xhr) ->
    if xhr.responseJSON?
      alert xhr.responseJSON.message
    else
      alert('操作失败')
