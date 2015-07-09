
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

function sendNewMobile() {
  var mobile = $('#new_mobile').val();
  var checkNum = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/;
  if (checkNum.test(mobile)) {
    $.ajax({
      url: '/mobile_auth_code/create',
      type: 'POST',
      data: {mobile: mobile},
    })
    .always(function() {
      console.log("complete");
      timedown($('#send_mobile'))
    });
  };
  console.log(mobile);
  if (!checkNum.test(mobile)) {alert("手机格式错误")};

}

var _time = 60;
function timedown( t ){
  console.log(t);
  if( _time == 0 ){
    t.prop("disabled",'');
    t.attr('value',"发送验证码");
    _time = 60;
  }else {
    t.prop("disabled", "disabled");
    t.attr('value', ""+_time+"秒后再次获取");
    _time--;
    setTimeout(function() {
      timedown(t)
    },1000);
  }
}
// orders#new
