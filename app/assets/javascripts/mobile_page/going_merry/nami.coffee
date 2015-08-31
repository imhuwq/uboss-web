class GoingMerry.Nami

  constructor: ->
    @pay_env = 'production'

  setPayenv: (env) ->
    @pay_env = env

  chooseWXPay: (args)->
    if @pay_env == 'test'
      do args.success
    else
      wx.chooseWXPay(args)

UBOSS.nami = new GoingMerry.Nami
