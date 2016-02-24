
server '10.17.10.101', user: 'deploy', roles: %w{web app db}
#server '10.17.10.102', user: 'deploy', roles: %w{web app}

set :deploy_user, 'deploy'
set :branch, 'master'
set :rails_env, 'production'
