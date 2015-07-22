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

UBoss.nami = new GoingMerry.Nami
