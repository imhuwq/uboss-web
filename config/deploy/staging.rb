
server 'op.uboss.me', user: 'deploy', roles: %w{web app db}, port: 2201

set :deploy_user, 'deploy'
set :branch, 'staging'
set :rails_env, 'staging'
