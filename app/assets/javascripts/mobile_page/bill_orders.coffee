$ ->
  requesting_bill = false
  $('.req-bill-btn').on 'click', (e)->
    e.preventDefault()
    return false if requesting_bill
    pay_amount = Number($('#pay_amount').val())
    if not pay_amount > 0
      alert('请输入付款金额')
      return false
    ssid = $('#service_store_id').val()
    requesting_bill = true
    $.ajax
      url: $(this).attr('href'),
      type: 'POST',
      data:
        pay_amount: pay_amount
        ssid: ssid
    .done (data)->
      UBoss.nami.chooseWXPay
        "timestamp": data.timeStamp
        "nonceStr":  data.nonceStr
        "package":   data.package
        "signType":  data.signType
        "paySign":   data.sign
        "success":   (res) ->
          window.location.href = "/charges/" + data.order_charge_id + "/bill_complete"
    .fail (xhr, errorType, error)->
      alert(
        try
          JSON.parse(xhr.responseText).message
        catch error
          '付款请求失败'
      )
    .always ->
      requesting_bill = false
