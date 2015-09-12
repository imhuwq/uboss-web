//= require zepto/zepto.min
//= require zepto/plugins/fx
//= require zepto/plugins/fx_methods
//= require zepto/plugins/callbacks
//= require zepto/plugins/deferred
//= require fastclick
//= require rails-behaviors/index
//= require zepto.waypoints.min.js
//= require mobile_page/going_merry
//= require mobile_page/order
//= require mobile_page/account
//= require mobile_page/sms
//= require mobile_page/utilities
//= require shared/login
//= require shared/city_select
//= require_self

$(function() {

  FastClick.attach(document.body);

  $('form').on('keyup keypress', function(e) {
    var code = e.keyCode || e.which;
    if (code == 13) {
      e.preventDefault();
      return false;
    }
  });

	$("header .right").on('click', function() {
    $('.nav_bar').toggle();
	});

});

function close_window() {
  $('.menb').remove();
}
