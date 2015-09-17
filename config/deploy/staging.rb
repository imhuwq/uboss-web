
server 'op.uboss.me',
  user:  'deploy',
  roles: %w{web app db},
  port:  2201,
  ssh_options: {
    keys: ["#{ENV['HOME']}/.ssh/uboss_stage.pem"],
    forward_agent: true
  }

set :deploy_user, 'deploy'
set :branch, 'staging'
set :rails_env, 'staging'
