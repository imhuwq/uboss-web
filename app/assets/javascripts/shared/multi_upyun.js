window.onload=function(){
	document.getElementById('upload').onclick = function() {
		console.log(1)
		var ext =document.getElementById('file').files[0].name.split('.').pop();
	
		var config = {
			form_api_url: 'http://v0.api.upyun.com',
	  	username: 'ulaiberdev',
	  	password: 'ulaiber2015',
	  	bucket: 'ssobu-dev',
	  	bucket_key: 'vaQU6JGHQC8HamRHEeT9izlhHqE=',
	  	bucket_host: 'http://ssobu-dev.b0.upaiyun.com'
			
			
		};
	
		var instance = new Sand(config);
		var options = {
			'notify_url': 'http://ssobu-dev.b0.upaiyun.com'
		};
	
		instance.setOptions(options);
		instance.upload('/asset_img/avatar/' + ext);
	};
	
	
		// demo stuff
	function addLog(data) {
	  var elem = document.createElement("ul");
	  for (var key in data) {
	  	if(key === 'path') {
	  		elem.innerHTML += '<li><strong>' + key + ':</strong>' + '<a target="_blank"  href="http://ssobu-dev.b0.upaiyun.com' + data[key] + '">' + data[key] + '</a>' + '</li>';
	  	} else {
	  		elem.innerHTML += '<li><strong>' + key + ':</strong>' + data[key] + '</li>';
	  	}
	
	  }
	  log.appendChild(elem);
	  console.log(2)
	}
	
	document.addEventListener('uploaded', function(e) {
		var log = document.getElementById("log");
		addLog(e.detail);
	});
}