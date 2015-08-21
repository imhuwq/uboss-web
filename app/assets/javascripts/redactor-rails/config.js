window.init_redactor = function(){
  var csrf_token = $('meta[name=csrf-token]').attr('content');
  var csrf_param = $('meta[name=csrf-param]').attr('content');

  var params;
  if (csrf_param !== undefined && csrf_token !== undefined) {
      params = csrf_param + "=" + encodeURIComponent(csrf_token);
  }

  $('.redactor').redactor({
    buttons: [
      'html',          'formatting',  'bold',    'italic', 'deleted', 'underline',
      'unorderedlist', 'orderedlist', 'outdent', 'indent',
      'image',         'alignment',   'horizontalrule'
    ],
    plugins: ['fontsize', 'fontcolor', 'imagemanager'],
    imageManagerJson: '/redactor_rails/pictures',
    imageUpload: "/redactor_rails/pictures?" + params,
    imageGetJson: "/redactor_rails/pictures",
    imageEditable: false,
    path: "/assets/redactor-rails",
    css: "style.css",
    lang: 'zh_cn'
  });
}

$(document).on('ready page:load', window.init_redactor);
