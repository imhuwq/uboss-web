#= require zepto/zepto.min
#= require zepto/plugins/fx
#= require zepto/plugins/fx_methods
#= require zepto/plugins/callbacks
#= require zepto/plugins/deferred
#= require fastclick
#= require rails-behaviors/index
#= reuqire_self

$ ->

  FastClick.attach document.body

  $('form').on 'keyup keypress', (e) ->
    code = e.keyCode || e.which
    if (code == 13)
      e.preventDefault()
      return false

	$("header .right").on 'click', ->
    $('header .nav').toggle()
