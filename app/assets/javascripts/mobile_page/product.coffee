$ ->
  # 加入购物车 TODO maybe in product.coffee
  $('.js-add-cart').on 'click', (e)->
    e.preventDefault()
    product_id = Number($('.cart-product-id').val())
    count = Number($('.cart-count').val())

    if count >= 1
      $.ajax
        url: '/cart_items'
        type: 'POST'
        data: {product_id: product_id, count: count}
        success: (res) ->
          if res['status'] == "ok"
            alert('添加成功，购物车有'+res['cart_items_count']+'件商品')
            # TODO do something
          else
            location.reload()
            # TODO do something
        error: (data, status, e) ->
          alert("ERROR")
    else
      alert "请填写正确的商品数量"
