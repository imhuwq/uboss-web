$(document).on 'click',"[data-behavior='changeStatus']" , (event) ->
  event.preventDefault()
  data = $(this).data()
  page = App.params.page
  $.ajax
    url: '/admin/certifications/' + data.id + '/change_status',
    dataType: 'script',
    method: 'PUT',
    data: { status: data.to, page: page }