namespace :db do

  task :seed do
    on primary :db do |host|
      info '[db:seed] Run `rake db:seed`'
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:seed"
        end
      end
    end
  end

end
