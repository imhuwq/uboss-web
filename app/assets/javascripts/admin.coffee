#= require jquery
#= require modernizr-2.6.2.min
#= require china_city/jquery.china_city
#= require jquery_nested_form
#= require jquery_ujs
#= require bootstrap-sprockets
#= require redactor-rails
#= require redactor-rails/plugins/imagemanager
#= require redactor-rails/langs/zh_cn
#= require redactor-rails/config
#= require chosen.jquery.min
#= require select2
#= require jquery-fileupload/basic
#= require querystring
#= require shared/upyun
#= require_tree ./admin
#= require_self

jQuery ($) ->

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
