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
    height = 200
    if ($('.nav_bar').height() > 0) {
      height = 0
    }
    $(".nav_bar").css({
      'height': height
    })
	});

  // $(".my_menu ul li").click(function(){
  //   var Index = $(this).index();
  //   $(this).addClass('active').siblings().removeClass('act∏∏ive');
  //   $('my_acuntbox2').children('.qre').eq(Index).show().siblings('.qre').hide();
  // });

});

function close_window() {
  $('#window').html('');
}


window.onresize = function(){
  // if (g == document.documentElement.clientHeight && h == document.documentElement.clientWidth){
  //   renderPage();
  //   console.log('renderPage')
  // }
  if (g/h > document.documentElement.clientHeight/document.documentElement.clientWidth){
    renderPage();
    console.log('renderPage')
  }
  // console.log('g= ' + g)
  // console.log('document.documentElement.clientHeight= ' + document.documentElement.clientHeight)
  // console.log('h= ' + h)
  // console.log('document.documentElement.clientWidth= ' + document.documentElement.clientWidth)
};
