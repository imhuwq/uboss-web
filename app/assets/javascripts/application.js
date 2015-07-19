//= require mobile_page/autoStrap
//= require jquery
//= require jquery_ujs
//= require fastclick
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
