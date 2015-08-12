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

set :jianliao_uri, URI(URI.encode("https://hook.lesschat.com/incoming/f4636adaa386472ebd218d9ef83d423b"))

namespace :deploy do

  after 'deploy:publishing', 'deploy:restart'
  task :restart do
    invoke 'unicorn:restart'
  end

  after :finishing, 'deploy:cleanup'

  task :starting_notify do
    Net::HTTP.post_form(fetch(:jianliao_uri),
                        text: "#{`git config user.name`} Starting Deploy branch `#{fetch(:branch)}`")
  end
  after 'deploy:starting', 'deploy:starting_notify'

  task :notify do
    Net::HTTP.post_form(fetch(:jianliao_uri),
                        text: "#{`git config user.name`} Deploy branch `#{fetch(:branch)}` SUCCESS.")
  end
  after 'deploy:finished', 'deploy:notify'

end
