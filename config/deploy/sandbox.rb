
server '192.168.33.10', user: 'deploy', roles: %w{app}

set :deploy_user, 'deploy'
set :branch, 'master'
set :rails_env, ENV['RAILS_ENV'] || 'staging'
