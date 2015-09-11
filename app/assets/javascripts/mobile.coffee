#= require zepto/zepto.min
#= require zepto/plugins/fx
#= require zepto/plugins/fx_methods
#= require zepto/plugins/callbacks
#= require zepto/plugins/deferred
#= require rails-behaviors/index
#= require fastclick
#= require swipe
#= reuqire_self

$ ->

  FastClick.attach document.body

  $('form').on 'keyup keypress', (e) ->
    code = e.keyCode || e.which
    if (code == 13)
      e.preventDefault()
      return false

  new Swipe document.getElementById('slider'),
    speed: 300
    auto: 5000
    continuous: true
    disableScroll: false
    stopPropagation: true
    transitionEnd: (index, elem) ->
      $('#slider-points span').removeClass('active')
      $('#slider-points span').eq(index).addClass('active')

  $("header .menu-btn").on 'click', ->
    $('header .nav-bar').toggle()
