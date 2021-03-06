#= require jquery
#= require modernizr-2.6.2.min
#= require china_city/jquery.china_city
#= require jquery_nested_form
#= require jquery_ujs
#= require bootstrap-sprockets
#= require redactor-rails/redactor
#= require redactor-rails/plugins/imagemanager
#= require redactor-rails/langs/zh_cn
#= require chosen.jquery.min
#= require select2
#= require select2_locale_zh-CN
#= require jquery-fileupload/basic
#= require jquery.bxslider
#= require querystring
#= require pnotify.custom.min
#= require admin/carriage_template
#= require admin/dashboard
#= require admin/functions
#= require admin/order
#= require admin/product
#= require admin/redactor-config
#= require admin/sms
#= require admin/category
#= require admin/store
#= require admin/user_address
#= require admin/refund
#= require admin/platform_advertisement
#= require shared/upyun
#= require shared/multi_upyun_admin
#= require shared/count_down
#= require admin/certification
#= require admin/sellers
#= require admin/promotion_activity
#= require admin/calling_notify
#= require_self

App = window.App = {}
$ ->
  App.params = jQuery.parseJSON($('body').attr('data-params'))

jQuery ($) ->

  $(".box-num h1.num").each ->
    ls=$(this).html().length
    ls_num= $(this).html().replace(/,/g,'').slice(2,ls)
    ls_num_size=ls_num.length
    if ls_num_size>13
     $(this).html('￥ '+ls_num.slice(0,ls_num_size-10)+'千万')
    else if ls_num_size>10
     $(this).html('￥ '+ls_num.slice(0,ls_num_size-7)+'万')

  $("body").on 'click',"#check_all", ->
    $(".check").attr("checked",this.checked)

  $('[data-toggle="tooltip"]').tooltip()

  $('[data-toggle="popover"]').popover()

  $('.tab-title').click ->
    if !$(this).hasClass('active')
      $('.header-tab .tab-title').removeClass 'active'
      $(this).addClass 'active'
      $('.tab-content').hide()
      tabid = $(this).attr('data-title')
      $(tabid).fadeIn()
    return

  $("select").filter(":not([data-manual-chosen])").chosen()


  $(document).on 'change', '.update_item', ->
    $this = $(this)
    resource_val = $this.val()
    resource_path = $this.attr('data-url')
    $.ajax
      url: resource_path
      type: 'POST'
      data: {resource_val:  resource_val}
      success: (res) ->
        console.log "res", res
        if res['error']
          alert(res['error'])
          $this.val('')
      error: (data, status, e) ->
        console.log data, status, e
        alert("操作错误")

  $('.cooperation').on 'show.bs.modal', ->
    $('.list-table tr:hover td').css('opacity', '1')

  $('.cooperation').on 'hide.bs.modal', ->
    $('.list-table tr:hover td').removeAttr('style')

  $('.show-order-modal').on 'show.bs.modal', ->
    $('.list-table tr:hover td').css('opacity', '1')

  $('.show-order-modal').on 'hide.bs.modal', ->
    $('.list-table tr:hover td').removeAttr('style')

  $('#card-link').hover(->
    $('#card-dropdown-menu').toggle()
  ).click ->
    $('#card-dropdown-menu').toggle()

  $('#card-dropdown-menu').hover ->
    $('#card-dropdown-menu').toggle()

  $(document).on 'click', '.show-value span a', ->
    $(this).closest('.show-value').siblings().show()
    $(this).closest('.show-value').hide()


  $(".user_selection").select2
    width: 500
    placeholder: '请选择用户'
    allowClear: true
    minimumInputLength: 2
    ajax:
      url: "/admin/sellers/search"
      dataType: 'json'
      data: (term, page) ->
        return { q: term, page_limit: 10 }
      results: (data, page) ->
        return {results: data}
    initSelection: (ele, callback) ->
      #callback({id: 1, text: 'Mock User'})
      id = $(ele).val()
      if(id!="")
        $.ajax("/admin/sellers/search", data: {id: id}, dataType: 'json')
         .done (data) ->
           callback(data)
