$ ->
  $('.recommend_link').on 'click', (e) ->
    e.preventDefault()
    user_id = $('.recommend_link').attr('user_id')
    recommended_id = $('.recommend_link').attr('recommended_id')
    recommended_type = $('.recommend_link').attr('recommended_type')
    if user_id == ''
      alert('请先登录')
      return
    if $('.recommend_link').hasClass('has_recommend')
      $.ajax
        url: "/recommends/0"
        type: 'DELETE'
        data: {user_id: user_id, recommended_id: recommended_id, recommended_type: recommended_type}
        success: (res) ->
          if res['status'] == "ok"
            $('.recommend_link').removeClass('has_recommend')
        error: (data, status, e) ->
          alert('操作失败')
          return false
    else
      $.ajax
        url: '/recommends'
        type: 'POST'
        data: {user_id: user_id, recommended_id: recommended_id, recommended_type: recommended_type}
        success: (res) ->
          if res['status'] == "ok"
            $('.recommend_link').addClass('has_recommend')
        error: (data, status, e) ->
          alert('操作失败')
          return false
