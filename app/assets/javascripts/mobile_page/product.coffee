$ ->
  # 加入购物车 TODO maybe in product.coffee
  $('.js-add-cart').on 'click', (e)->
    e.preventDefault()
    product_id = Number($("input[name='product[id]']").val())
    count = Number($("input[name='product[count]']").val())

    if count >= 1
      $.ajax
        url: '/cart_items'
        type: 'POST'
        data: {product_id: product_id, count: count}
        success: (res) ->
          if res['status'] == "ok"
            alert('添加成功，购物车有'+res['cart_items_count']+'件商品')
            # TODO do something. 购物车标记空与不空
          else
            location.reload()
            alert(res['message'])
        error: (data, status, e) ->
          alert("ERROR")
    else
      alert "请填写正确的商品数量"
