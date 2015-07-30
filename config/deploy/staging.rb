
server '10.17.1.51', user: 'deploy', roles: %w{web app db}, port: 2201

set :deploy_user, 'deploy'
set :branch, 'master'
set :rails_env, 'staging'
