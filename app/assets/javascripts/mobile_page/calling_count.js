function calling_count (that,i){		
		that.text("呼叫"+ i +"s");
		i= i -1;
		if(i < 0){
			setTimeout(function(){
				calling_count (that,i)
			},1000)
		}else{
			that.text("呼叫");
		}
	
}
