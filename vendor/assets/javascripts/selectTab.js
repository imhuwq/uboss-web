/*
 * 入门教程点击切换
 */
	window.flag1_id = "tutorial1";			//消费者入门教程，上次选中标签的标识
	$('.page1_tab .tabs').click(function(){
		var exElement = $('#'+flag1_id+' div');
		exElement.eq(0).addClass('orange_circle_unswitched').removeClass('orange_circle');
		exElement.eq(1).addClass('ui-tutorial-circle-unswitched').removeClass('ui-tutorial-circle-switched');
		exElement.eq(2).addClass('ui-tutorial-tab-unswitched').removeClass('ui-tutorial-tab-switched');
		switch(flag1_id){
			case "tutorial1":$('.content1_tab1').css('display','none');break;
			case "tutorial2":$('.content1_tab2').css('display','none');break;
			case "tutorial3":$('.content1_tab3').css('display','none');break;
			case "tutorial4":$('.content1_tab4').css('display','none');break;
			case "tutorial5":$('.content1_tab5').css('display','none');break;
			case "tutorial6":$('.content1_tab6').css('display','none');break;
			default:break;
		}
		var element = $(this);
		var id = element.attr('id');
		window.flag1_id =id;
		element.children('div').eq(0).addClass('orange_circle').removeClass('orange_circle_unswitched');
		element.children('div').eq(1).addClass('ui-tutorial-circle-switched').removeClass('ui-tutorial-circle-unswitched');
		element.children('div').eq(2).addClass('ui-tutorial-tab-switched').removeClass('ui-tutorial-tab-unswitched');
		switch(id){
			case "tutorial1":$('.content1_tab1').css('display','block');break;
			case "tutorial2":$('.content1_tab2').css('display','block');break;
			case "tutorial3":$('.content1_tab3').css('display','block');break;
			case "tutorial4":$('.content1_tab4').css('display','block');break;
			case "tutorial5":$('.content1_tab5').css('display','block');break;
			case "tutorial6":$('.content1_tab6').css('display','block');break;
			default:break;
		}
	});
	/*
	 * 常见问题点击切换
	 */
	window.flag2_id = "issues1";
	$('.page2_tab .tabs').click(function(){
		var exElement = $('#'+flag2_id+' div').addClass('ui-issues-tab-unswitched').removeClass('ui-issues-tab-switched');
		switch(flag2_id){
			case "issues1":$('.content2_tab1').css('display','none');break;
			case "issues2":$('.content2_tab2').css('display','none');break;
			case "issues3":$('.content2_tab3').css('display','none');break;
			case "issues4":$('.content2_tab4').css('display','none');break;
			case "issues5":$('.content2_tab5').css('display','none');break;
			case "issues6":$('.content2_tab6').css('display','none');break;
			case "issues7":$('.content2_tab7').css('display','none');break;
			default:break;
		}

		var element = $(this);
		var id = element.attr('id');
		window.flag2_id =id;
		element.children('div').addClass('ui-issues-tab-switched').removeClass('ui-issues-tab-unswitched');
		switch(id){
			case "issues1":$('.content2_tab1').css('display','block');break;
			case "issues2":$('.content2_tab2').css('display','block');break;
			case "issues3":$('.content2_tab3').css('display','block');break;
			case "issues4":$('.content2_tab4').css('display','block');break;
			case "issues5":$('.content2_tab5').css('display','block');break;
			case "issues6":$('.content2_tab6').css('display','block');break;
			case "issues7":$('.content2_tab7').css('display','block');break;
			default:break;
		}
	});
