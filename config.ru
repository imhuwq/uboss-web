# This file is used by Rack-based servers to start the application.

if defined?(Unicorn)
  require 'unicorn/oob_gc'
  require 'unicorn/worker_killer'

  use Unicorn::OobGC, 10

  use Unicorn::WorkerKiller::MaxRequests, 3072, 4096

  use Unicorn::WorkerKiller::Oom, (292*(1024**2)), (356*(1024**2))
end

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
