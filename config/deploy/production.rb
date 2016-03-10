
server 'uboss-web-0', user: 'deploy', roles: %w{web app db}
server 'uboss-web-1', user: 'deploy', roles: %w{web app}
server 'uboss-web-2', user: 'deploy', roles: %w{web app}

set :deploy_user, 'deploy'
set :branch, 'master'
set :rails_env, 'production'
