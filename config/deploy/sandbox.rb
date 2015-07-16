
server 'ssobu.vagrant.lo', user: 'deploy', roles: %w{web app db}

set :deploy_user, 'deploy'
set :branch, 'master'
set :rails_env, 'staging'
