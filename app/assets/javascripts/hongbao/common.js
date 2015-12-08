$(function(){

	window.vv={};
	vv.gamePoint=1;
	vv.gameTime=8;
	vv.gameCTime=0;
	vv.gameTimer=false;
  vv.geting=false;

	var Edown, Eup, Emove;
	if($.os.phone){
		Edown='touchstart';
		Eup='touchend';
		Emove='touchmove';
	}else{
		Edown='mousedown';
		Eup='mouseup';
		Emove='mousemove';
	}

	window.touchX=undefined;
	window.touchY=undefined;
	window.touchMX=undefined;
	window.touchMY=undefined;
	$(document).on(Edown,function(e){
		if($.os.phone){
			touchX = e.targetTouches[0].pageX;
			touchY = e.targetTouches[0].pageY;
		}else{
			touchX = e.pageX;
			touchY = e.pageY;
		}
	})
	$(document).on(Emove,function(e){
		if($.os.phone){
			touchMX = e.targetTouches[0].pageX-touchX;
			touchMY = e.targetTouches[0].pageY-touchY;
		}else{
			touchMX = e.pageX-touchX;
			touchMY = e.pageY-touchY;
		}
	});

	/***** onload *****/
	var progress=0;
	$("img").on('load',function(){
		$(this).addClass('loaded');
		progress=parseInt($(".loaded").size()/$("img").size()*100);
		$(".loading var").text(progress+'%');
		if(progress == 100){
			$(".loading").fadeOut(200,function(){
				$(".page1").fadeIn(200);
			})
		}
	})
	$(window).load(function(){
		$(".loading").fadeOut(200,function(){
			$(".page1").fadeIn(200);
		})
	})
	/* 跳转到游戏规则  */
	$('.page1-btn1').on(Edown,function(){
		$('section:visible').fadeOut(100,function(){
			$('.game-rule').fadeIn(200);
		})
	})
	/*** 跳转到游戏页面 ***/
	$('.page1-btn').on(Edown,function(){
		$('section:visible').fadeOut(100,function(){
			$('.page2').fadeIn(200);
		})
	})

	//开始游戏
	$('.page2-btn').on(Edown,function(){
		$('.page2 .pop-container').fadeOut(100,function(){
			vv.gamePoint=0;
			$('.page2').fadeIn(200);
			sqBegin();
		})
	})

	/***** game *****/
	function sqBegin(){
		if(vv.gameTimer){ return;}
		var timer_msec=1;
		var startTime = Date.now();
		window.clearInterval(vv.gameTimer);
		$(".game-info .game-time var").text(vv.gameTime+"'00");
		vv.gameTimer=window.setInterval(function(){
			currentTime = vv.gameTime * 1000 - (Date.now() - startTime);
			second = (currentTime / 1000).toFixed(0);
			millionSecond = ((currentTime % 1000) / 10).toFixed(0);
			if(millionSecond<10){
				$(".game-info .game-time var").text(second+"'0"+millionSecond);
		  }else{
		  	$(".game-info .game-time var").text(second+"'"+millionSecond);
		  }
			if(currentTime<0){
				window.clearInterval(vv.gameTimer);
				vv.gameTimer=false;
				touchMY=0;
				$(".game-info .game-time var").text("0'00");
				goResult();

			}
		},10)
	}

	/* 游戏结果计算 */
	function goResult(){
		$('.page3 .game-result-number').text((vv.gamePoint*0.1).toFixed(1)+'元');
		if(vv.gamePoint > 45 ){
			$('.page3 .game-exceed').text('99');
		}else if(vv.gamePoint > 40){
			$('.page3 .game-exceed').text('95');
		}else if(vv.gamePoint > 30){
			$('.page3 .game-exceed').text('88');
		}else if(vv.gamePoint > 20){
			$('.page3 .game-exceed').text('50');
		}else if(vv.gamePoint > 10){
			$('.page3 .game-exceed').text('8');
		}else{
			$('.page3 .game-exceed').text('0');
		}
		$('section:visible').fadeOut(100,function(){
			$('.page3').fadeIn(200);
		})
	}

	$(".game-main-icon span").on(Edown,function(){
		if(vv.gameCTime==vv.gameTime){ sqBegin(); }
		$(".game-main-icon .qq").size()==0 && $(".game-main-icon span").append($(".game-main-icon span img").eq(0).clone().attr('class','qq'));
	})
	$(".game-main-icon span").on(Emove,function(e){
		e.preventDefault();
		if(vv.gameCTime<0){ return; }
		$(".game-main-icon .qq").css('-webkit-transform', 'translateY('+touchMY*4+'px)');
	})
	$(".game-main-icon span").on(Eup,function(e){
		var offsetY=touchMY;
		touchMY=0;
		if(vv.gameCTime<0){ return; }
		if(offsetY<-100){
			vv.gamePoint+=1;
			$(".game-info .game-count").text(vv.gamePoint);
			$(".game-main-icon .qq").attr('class','qqq').animate({translateY:-$(".wrapper").height()*2+'px', scaleX:0.7, scaleY:0.7}, 1000, function(){ $(this).remove(); })
		}else{
			$(".game-main-icon .qq").animate({translateY:'0px'}, 100);
		}
	})

	/* end game */
	/* 再玩一次  */
	$('.page3-btn').on(Edown,function(){
		$('section:visible').fadeOut(100,function(){
			vv.gamePoint=0;
			$('.game-info .game-count').text('0');
			$(".game-info .game-time var").text("0'00");
			$('.page3 .pop-container').addClass('hidden');
			$('.page3 .share-box').addClass('hidden');
			$('.page2 .pop-container').fadeIn();
			$('.page2').fadeIn(200);
		})
	})

	/* page3 弹出框 */
	$('.page3-btn3').on('click',function(){
		var user_tel = $('#mobile-input').val();
		var Is_mobile = !!user_tel.match(/^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/);
		if(!Is_mobile){
			alert('请输入正确的手机号码');
		}else{
      if (vv.geting) {
        return false;
      }
      vv.geting = true;
      $.ajax({
        url: '/bonus',
        type: 'POST',
        data: {mobile: user_tel, amount: (vv.gamePoint*0.1).toFixed(1)},
      }).done(function(){
        $('.mobile-number').text(user_tel);
        $('.page3 .pop-container').removeClass('hidden');
        vv.geting = false;
      }).fail(function(xhr, status){
        vv.geting = false;
        try {
          alert(JSON.parse(xhr.responseText).message);
        } catch (e) {
          alert('领取失败');
        }
      })
		}
	});

	$('.page3-btn2').on('click',function(){
		$('.page3 .share-box').removeClass('hidden');
	});

	$('.page3 .share-box').on('click',function(){
		$(this).addClass('hidden');
	})

  function preventDefault(ev) {
    ev.preventDefault()
  }
  document.addEventListener('touchmove', preventDefault, false)
})
