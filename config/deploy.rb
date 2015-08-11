# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'ssobu'
set :deploy_user, 'deploy'
set :deploy_to, "/home/#{fetch(:deploy_user)}/rails/#{fetch(:application)}"

set :scm, :git
set :repo_url, 'git@gitlab.ulaiber.com:uboss/uboss-web.git'

set :rbenv_type, :user
set :rbenv_ruby, '2.2.2'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :unicorn_config_path, -> { File.join(current_path, "config", "unicorn.rb") }
set :unicorn_rack_env, -> { fetch(:rails_env) == "development" ? "development" : "staging" }

set :sidekiq_config, -> { File.join(current_path, "config", "sidekiq.yml") }
set :conditionally_migrate, true
set :assets_roles, [:web, :app]
set :keep_releases, 5

set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml', 'config/secrets.yml', 'config/apiclient_cert.p12'
)
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/assets'
)

namespace :deploy do

  after 'deploy:publishing', 'deploy:restart'
  task :restart do
    invoke 'unicorn:restart'
  end

  after :finishing, 'deploy:cleanup'

  task :notify do
    uri = URI(URI.encode("https://jianliao.com/v1/services/webhook/608331ce12bc4e491d7f358c467a71a6e2fa9d9f"))
    Net::HTTP.post_form(uri, authorName: `git config user.name`, title: "Deploy branch #{fetch(:branch)}")
  end
  after 'deploy:restart', 'deploy:notify'

end
