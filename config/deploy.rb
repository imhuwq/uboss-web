# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'ssobu'
set :deploy_user, 'deploy'
set :deploy_to, "/home/#{fetch(:deploy_user)}/rails/#{fetch(:application)}"

set :scm, :git
set :repo_url, 'git@github.com:xEasy/uboss.git'

set :rbenv_type, :user
set :rbenv_ruby, '2.2.2'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :unicorn_config_path, -> { File.join(current_path, "config", "unicorn.rb") }
set :unicorn_rack_env, -> { fetch(:rails_env) == "development" ? "development" : "staging" }

set :keep_releases, 5

set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml', 'config/secrets.yml', 'config/apiclient_cert.p12'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/assets'
)

namespace :deploy do

  after 'deploy:publishing', 'deploy:restart'
  namespace :deploy do
    task :restart do
      invoke 'unicorn:restart'
    end
  end

  after :finishing, 'deploy:cleanup'

end
