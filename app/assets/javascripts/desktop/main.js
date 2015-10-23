$(window).load(function() {
  	$('.banner .content').fadeIn()
})
$(document).ready(function() {
  	$('.banner .content').hide()
	if(navigator.appName == "Microsoft Internet Explorer" && navigator.appVersion .split(";")[1].replace(/[ ]/g,"")=="MSIE8.0"){
		$('#number span').text('8,349,375')
  	}else{
		var comma_separator_number_step = $.animateNumber.numberStepFactories.separator(',')
		$(window).scroll(function(){
			if($('#number').hasClass('animated')){
				setTimeout(function(){
					$('#number span').animateNumber(
					  {
					    number: 8349375,
					    numberStep: comma_separator_number_step
					  }
					);
				},3500)
				
			}
		})
	}
    $(".video-banner").click(function (){
    	var isrc=$(this).attr('data-src');
    	$(".video-bg").fadeIn();
    	$(".video-box").prepend('<embed class="player" src="'+isrc+'" allowFullScreen="true" quality="high" width="600" height="400" align="middle" allowScriptAccess="always" type="application/x-shockwave-flash"></embed><div class="close"><i class="fa fa-times"></i></div>')
    });
    $(".video-box").on("click",".close",function(){
    	$(".video-bg").fadeOut();
    	$(".video-box").empty();
    });
    $('#pagepiling').pagepiling({
        menu: null,
        direction: 'vertical',
        verticalCentered: true,        
        scrollingSpeed: 700,
        easing: 'swing',     
        keyboardScrolling: true,
        sectionSelector: '.section',

        //events
        onLeave: function(index, nextIndex, direction){
        	if(nextIndex != 1 && nextIndex != 7){
        		$('header').fadeOut()
        	}else{
        		$('header').show()
        	}
        },
        afterLoad: function(anchorLink, index){},
        afterRender: function(){},
    });
})