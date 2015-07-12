
function close_window() {
	$('#window').html('');
}
$('body').on('ajax.success', this, function(event) {
	console.log("success");
});
$('body').ajaxSuccess(function(){
  alert("AJAX 请求已成功完成");
  console.log("success");
});
$('body').prop('class');

// orders#new
