json.extract!(resource, :id, :login, :email, :admin, :nickname, :avatar_url)
json.csrf_param @csrf_param
json.csrf_token @csrf_token
