class GoingMerry.Chopper
  constructor: ->
    @mobileRegx = /^(\+\d+-)?[1-9]{1}[0-9]{10}$/

  valifyMobile: (mobile) ->
    @mobileRegx.test(mobile)

UBOSS.chopper = new GoingMerry.Chopper
