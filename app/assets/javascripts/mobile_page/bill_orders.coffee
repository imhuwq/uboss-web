$ ->

  requesting_bill = false
  requested_data_cache = {}
  pay_amount = Number($('#pay_amount').val())
  ssid = $('#service_store_id').val()

  invokePayment = (data) ->
    UBoss.nami.chooseWXPay
      "timestamp": data.timeStamp
      "nonceStr":  data.nonceStr
      "package":   data.package
      "signType":  data.signType
      "paySign":   data.sign
      "success":   (res) ->
        window.location.href = "/charges/" + data.order_charge_id + "/bill_complete"

  requestBill = (ssid, pay_amount) ->
    requesting_bill = true
    UBoss.chopper.showSpinner()
    $.ajax
      url: '/bill_orders'
      type: 'POST',
      data:
        pay_amount: pay_amount
        ssid: ssid
    .done (data)->
      requested_data_cache["bill-#{Number(data.pay_amount)}"] = data
      invokePayment(data)
    .fail (xhr, errorType, error)->
      alert(
        try
          JSON.parse(xhr.responseText).message
        catch error
          '付款请求失败'
      )
    .always ->
      requesting_bill = false
      UBoss.chopper.hideSpinner()

  # if pay_amount > 0
  #   requestBill(ssid, pay_amount)

  $('.req-bill-btn').on 'click', (e)->
    e.preventDefault()
    return false if requesting_bill
    pay_amount = Number($('#pay_amount').val())
    if not pay_amount > 0
      alert('请输入付款金额')
      return false
    if requested_data_cache["bill-#{pay_amount}"] != undefined
      invokePayment(requested_data_cache["bill-#{pay_amount}"])
      return false
    requestBill(ssid, pay_amount)

  UBoss.luffy.bindPCardTaker '.bill-sharing-cont .get-p-card-btn',
    beforeSendFuc: ->
      console.log 'before'
    successFuc: (data)->
      UBoss.luffy.showWxPopTip()
    failFuc: ->
      console.log 'fail'
    alwaysFuc: ->
      console.log 'alwaysFuc'

