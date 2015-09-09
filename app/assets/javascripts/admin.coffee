#= require jquery
#= require modernizr-2.6.2.min
#= require jquery_ujs
#= require bootstrap-sprockets
#= require redactor-rails
#= require redactor-rails/plugins/imagemanager
#= require redactor-rails/langs/zh_cn
#= require chosen.jquery.min
#= require jquery-fileupload/basic
#= require querystring
#= require shared/upyun
#= require_tree ./admin
#= require_self

$ ->
  $("body").on 'click',"#check_all", ->
    $(".check").attr("checked",this.checked)  
  
  $('[data-toggle="tooltip"]').tooltip();

  $('[data-toggle="popover"]').popover();
  

