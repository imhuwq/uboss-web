//= require zepto/zepto.min
//= require zepto/plugins/fx
//= require zepto/plugins/fx_methods
//= require zepto/plugins/touch
//= require zepto/plugins/callbacks
//= require zepto/plugins/deferred
//= require rails-behaviors/index
//= require zepto.waypoints.min.js
//= require mobile_page/utilities
//= require mobile_page/going_merry
//= require mobile_page/order
//= require mobile_page/account
//= require mobile_page/sms
//= require shared/login
//= require china_city/jquery.china_city
//= require shared/city_select
//= require_self

$(function() {

  $('form').on('keyup keypress', function(e) {
    var code = e.keyCode || e.which;
    if (code == 13) {
      e.preventDefault();
      return false;
    }
  });

	$("header .right").on('tap', function() {
    height = 200
    if ($('.nav_bar').height() > 0) {
      height = 0
    }
    $(".nav_bar").css({
      'height': height
    })
	});

});

function close_window() {
  $('#window').html('');
}
