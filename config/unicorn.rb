APP_ROOT = File.expand_path("../..", __FILE__)
ENV["RACK_ENV"] = ENV["RAILS_ENV"] ||= "production"

working_directory APP_ROOT
pid "#{APP_ROOT}/tmp/pids/unicorn.pid"
stderr_path "#{APP_ROOT}/log/unicorn.stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn.stdout.log"

listen "#{APP_ROOT}/tmp/unicorn.uboss.sock", :backlog => 64
listen 4096, :tcp_nopush => false
worker_processes ENV["RAILS_ENV"] == "production" ? 8 : 1
timeout 30

# To save some memory and improve performance
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

# Force the bundler gemfile environment variable to
# reference the Сapistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(APP_ROOT, 'Gemfile')
end

before_fork do |server, worker|

  old_pid = File.join APP_ROOT, "tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  # disable GC，using OOB，to reduce requesting time
  GC.disable

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  child_pid = server.config[:pid].sub(".pid", ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")
end
