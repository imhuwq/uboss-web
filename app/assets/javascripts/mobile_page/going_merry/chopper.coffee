class GoingMerry.Chopper
  constructor: ->
    @mobileRegx = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/
    @loadingHTMl = """
<div class="spinner">
  <div class="bounce1"></div>
  <div class="bounce2"></div>
  <div class="bounce3"></div>
</div>
    """

  valifyMobile: (mobile) ->
    @mobileRegx.test(mobile)

  showSpinner: ->
    if $('.spinner').length > 0
      $('.spinner').show()
    else
      $('body').append(@loadingHTMl)
      $('.spinner').show()

  hideSpinner: ->
    $('.spinner').hide()

UBoss.chopper = new GoingMerry.Chopper
