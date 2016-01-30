$ ->
  $(document).on 'ajax:success', '#products .switch-p-hot-btn', (e, data) ->
    if data.hot
      $(this).children('.fachange').removeClass('fa-heart-o').addClass('fa-heart red-color')
    else
      $(this).children('.fachange').removeClass('fa-heart red-color').addClass('fa-heart-o')

  $(document).on 'ajax:beforeSend', '#products .change-status-btn, .store-supplier-product, .list-supplier-product', (xhr, settings) ->
    return confirm("确定#{$(this).text()}?")

  $(document).on 'ajax:success', "#products .change-status-btn", (e, data) ->
    html = $("<div>#{data}</div>")
    window.html = html
    $('.admin-container').prepend(html.find('.alert'))
    if html.find('tbody .product').length > 0
      $(this).closest('.product').html(html.find('tbody .product').html())
    else
      $(this).closest('.product').remove()

  $(document).on 'ajax:error', "#products .change-status-btn, #products .switch-p-hot-btn, .actions .store-supplier-product, .actions .list-supplier-product", ->
    alert('操作失败')

  $('#ordinary_product_carriage_template_id').change (event) ->
    id = this.selectedOptions[0].value
    if id != ''
      $.ajax '/admin/select_carriage_template',
        type: 'GET'
        data: { tpl_id: id}
        false
      false
    else
      $('.select_carriage_template').remove()

  $('.product_transportation_way').find('input').change (event)->
    if $("label[for='ordinary_product_transportation_way_1']").find('input')[0].checked
      $('#ordinary_product_traffic_expense').focus()

    if !$("label[for='ordinary_product_transportation_way_1']").find('input')[0].checked
      $('#ordinary_product_traffic_expense').val('0.0')

    if $("label[for='ordinary_product_transportation_way_2']").find('input')[0].checked
      $('#ordinary_product_carriage_template_id_chosen').addClass('chosen-container-active chosen-with-drop')

    if !$("label[for='ordinary_product_transportation_way_2']").find('input')[0].checked
      $('.select_carriage_template').remove()
      $('#ordinary_product_carriage_template_id_chosen').removeClass('chosen-container-active chosen-with-drop')
      $('#ordinary_product_carriage_template_id_chosen').find('.chosen-single').find('span').text('请选择运费模板...')
      $('#ordinary_product_carriage_template_id option:selected').attr('selected', false)

  $("label[for='ordinary_product_full_cut']").click (event)->
    if $(this).find('input')[0].checked
      $('.full_cut_params').show()
      $(this).addClass('checkbox_is_checked')
      $(this).removeClass('checkbox_no_checked')
    else
      $('.full_cut_params').hide()
      $(this).addClass('checkbox_no_checked')
      $(this).removeClass('checkbox_is_checked')

  $(document).on "focusout", '#service_product_present_price', (event) ->
    $("a[data-level='1']").click()
    $('input.sku-price').val($(this).val()).focusout()
