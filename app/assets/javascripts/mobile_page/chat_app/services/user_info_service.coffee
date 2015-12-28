class UXin.Services.UserInfoServices

  userInfoCache: {}

  requestedUsers: {}

  getCache: (id)->
    @userInfoCache["user_#{id}"]

  setCache: (id, data)->
    @userInfoCache["user_#{id}"] = data

  getUserInfo: (targetId, callback) ->
    if @getCache(targetId)?
      return @getCache(targetId)

    return null if @requestedUsers[targetId]?
    @requestedUsers[targetId] = true
    $.getJSON '/chat/user_info',
      target_id: targetId
    , (data) =>
      unless @getCache(targetId)?
        @setCache(targetId, data)
      callback(data)
    null
