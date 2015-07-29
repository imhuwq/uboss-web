//= require mobile_page/autoStrap
//= require jquery
//= require jquery_ujs
//= require fastclick
//= require jquery.waypoints
//= require mobile_page/going_merry
//= require mobile_page/mobile
//= require mobile_page/order
//= require mobile_page/utilities
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

	$(".right").click(function() {
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
