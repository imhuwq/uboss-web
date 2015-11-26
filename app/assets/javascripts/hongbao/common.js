/* 2014 Web De: gongxy */


$(function(){
	window.vv={};
	vv.gamePoint=10;
	vv.gameTime=4;
	vv.gameCTime=0;
	vv.gameTimer=false;
	vv.updataed=false;
	vv.inviteNum=$("#invite").text()*1;
	vv.buyLink='http://www.wenjuan.com/s/eq6rEj/#rd';
	
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
	window.setTimeout(function(){
		$(".loading").fadeOut(200,function(){
			$(".s1").fadeIn(200);
		})
	},200)
	
	
	/***** ray *****/
	$(".ray").each(function(i,el){ //背景射线动画
		for(var n=0; n<20; n++){
			var temp=$(el).clone();
			temp.css('-webkit-transform','rotate('+Math.random()*360+'deg) scaleX('+(Math.random()*1+0.5)+')');
			temp.children('i').css('-webkit-animation-delay', (Math.random()*1-0.5)+'s');
			temp.insertAfter($(el));
		}
	})
	
	/***** cut *****/
	//到首页
	$('.s6 .btn2, .s7 .btn2').on(Edown,function(){ 
		$('section:visible').fadeOut(100,function(){
			$('.s1').fadeIn(200);
		})
	})
	//到代金券
	$('.s1 .btn2').on(Edown,function(){
		$('.s6 h3 var, .s7 h3 var').text(vv.inviteNum);
		$('section:visible').fadeOut(100,function(){
			vv.inviteNum>=16 ? $('.s7').fadeIn(200) : $('.s6').fadeIn(200);
		})
	})
	$('.s7 form a').on(Edown,function(){
		getChit();
	})
	//到游戏结果
	$('.s4 .btn2, .s5 .btn2').on(Edown,function(){
		goResult();
	})
	function goResult(){
		$('.s3 dt span').text(vv.gamePoint+'元');
		$('section:visible').fadeOut(100,function(){
			$('.s3').fadeIn(200);
		})
	}
	//到彩蛋(促销页)
	$('.s3 h6 a').on(Edown,function(){
		$('.wrapper').fadeOut(100,function(){
			$('.cx').fadeIn(200);
		})
	})
	$('.cx .btn2').on(Edown,function(){
		$('.cx').fadeOut(100,function(){
			$('.wrapper').fadeIn(200);
		})
	})
	$('.cx .btn1').on(Edown,function(){
		location.href=vv.buyLink;
	})
	//到排名
	$('.s3 .an2').on(Edown,function(){
		getRank()
		$('section:visible').fadeOut(100,function(){
			$('.s5').fadeIn(200);
		})
	})
	$('.s5 h5 a').on(Edown,function(){ $('.s5 label').fadeIn(100); })
	$('.s5 label').on(Edown,function(){ $('.s5 label').fadeOut(200); })
	//到分享
	$('.s3 .an3, .s6 .btn1').on(Edown,function(){  $('.share').fadeIn(100); })
	$('.share').on(Edown,function(){  $('.share').fadeOut(200); })
	//到游戏
	$('.s1 .btn1, .s3 .an1, .s5 .btn1').on(Edown,function(){ 
		vv.gamePoint=0;
		vv.gameCTime=vv.gameTime;
		$('section:visible').fadeOut(100,function(){
			$('.s2 h5 var').eq(0).text(vv.gameCTime.toFixed(1,10));
			$('.s2 h5 var').eq(1).text('000');
			$('.s2 h6').show();
			$('.s2 .qq, .s2 .qqq').remove();
			//$('.s2 dl').height($(document).height()-50)
			//$('.s2 dt, .s2 dd').height($(document).height()-$('.s2 h6').offset().top-$('.s2 h6').offset().height-40);
			$('.s2').fadeIn(200);
			window.setTimeout(function(){ sqBegin() },5000);
		})
	})
	
	/***** game *****/
	$(".s2 dt span").on(Edown,function(){
		if(vv.gameCTime==vv.gameTime){ sqBegin(); }
		$(".s2 dd .qq").size()==0 && $(".s2 dd").append($(".s2 dd q").eq(0).clone().attr('class','qq'));
	})
	$(".s2 dt span").on(Emove,function(e){
		e.preventDefault();
		if(vv.gameCTime<0){ return; }
		$(".s2 dd .qq").css('-webkit-transform', 'translateY('+touchMY*4+'px)');
	})
	$(".s2 dt span").on(Eup,function(e){
		var offsetY=touchMY;
		touchMY=0;
		if(vv.gameCTime<0){ return; }
		if(offsetY<-5){
			vv.gamePoint+=10;
			$(".s2 h5 var").eq(1).text(vv.gamePoint);
			$(".s2 dd .qq").attr('class','qqq').animate({translateY:-$(".wrapper").height()*2+'px', scaleX:0.7, scaleY:0.7}, 500, function(){ $(this).remove(); })
			createjs.Sound.play("qian", !0);
		}else{
			$(".s2 dd .qq").animate({translateY:'0px'}, 100);
		}
	})
	var soundTouched=false;
	$(document).on('touchstart',function(){
		!soundTouched && (soundTouched=true) && createjs.Sound.play("qian", !0);
	})
	function sqBegin(){
		if(vv.gameTimer){ return;}
		$(".s2 h6").hide();
		vv.gameTimer=window.setInterval(function(){
			vv.gameCTime-=0.1;
			var txtTime=vv.gameCTime*1;
			txtTime=txtTime.toFixed(1,10);
			if(txtTime.length<4){ txtTime='0'+txtTime; }
			$(".s2 h5 var").eq(0).text(txtTime);
			if(vv.gameCTime<0){
				window.clearInterval(vv.gameTimer);
				vv.gameTimer=false;
				vv.updataed=false;
				touchMY=0;
				$(".s2 h5 var").eq(0).text('00.0');
				window.setTimeout(function(){
					goResult();
				},1000)
			}
		},100)
	}
	
	
	//ajax排行数据
	function getRank(){
		if(vv.updataed ){ return;}
		$.ajax({
			type:"post",
			url:"your.php",
			async:false,
			data:{user:'微信账号', userName:'用户昵称', userIP:'ip地址', point:vv.gamePoint},
			dataType:'json',
			complete: function(data){ //开发时请将此处回调改为success；参考下面的data格式传递数据
				data={};
				data.myRank=339;
				data.rankList=[
					{rank:1, name:'张三李四', point:60800, imgsrc:'images/btn2.png'},
					{rank:2, name:'张三李四2', point:50800, imgsrc:'images/btn2.png'},
					{rank:3, name:'张三李四', point:40000, imgsrc:'images/btn2.png'},
					{rank:4, name:'张三李四4', point:39000, imgsrc:'images/btn2.png'},
					{rank:5, name:'张三李四5', point:38500, imgsrc:'images/btn2.png'},
					{rank:6, name:'张三李四6', point:26800, imgsrc:'images/btn2.png'},
					{rank:7, name:'张三李四', point:9900, imgsrc:'images/btn2.png'}
				];
				
				$(".s5 h3 var").text(data.myRank);
				$(".s5 dd").remove();
				$.each(data.rankList, function(i) {    
					$(".s5 dl").append('<dd><i><span>'+data.rankList[i].rank+'</span></i><em><img src="'+data.rankList[i].imgsrc+'" />'+data.rankList[i].name+'</em><var>￥<span>'+data.rankList[i].point+'</span></var></dd>')                                                       
				});
				vv.updataed=true;
			},
			error: function(){
				//开发时可以启用下面的代码
				//alert('通信错误，请检查网络！')
				//return false;
			}
		});
	}
	
	//ajax兑换代金券
	function getChit(){
		$.ajax({
			type:"post",
			url:"your.php",
			async:false,
			data:{user:'微信账号', userName:'用户昵称', userIP:'ip地址', chitCode:$('.s7 input').val() },
			dataType:'json',
			complete: function(data){ //开发时请将此处回调改为success；参考下面的data格式传递数据
				data.chitOK=1; //1:兑换成功， 0:兑换失败
				if(data.chitOK){
					alert('您的哈根达斯30元代金券兑换成功！')
					$(".s7 input").val('');
				}else{
					alert('兑换失败：请检查您的兑换码！')
				}
			},
			error: function(){
				//开发时可以启用下面的代码
				//alert('通信错误，请检查网络！')
				//return false;
			}
		});
	}
	

})
