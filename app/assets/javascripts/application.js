// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require mobile_page/autoStrap
//= require jquery
//= require jquery_ujs
//= require fastclick
//= require mobile_page/going_merry
//= require mobile_page/mobile
//= require mobile_page/order
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
		$(".nav_bar").slideToggle();
	});

  // $(".my_menu ul li").click(function(){
  //   var Index = $(this).index();
  //   $(this).addClass('active').siblings().removeClass('active');
  //   $('my_acuntbox2').children('.qre').eq(Index).show().siblings('.qre').hide();
  // });

});

function close_window() {
  $('#window').html('');
}
