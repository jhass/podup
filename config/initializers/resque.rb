require 'resque'
require 'resque_scheduler'

Resque.reset_delayed_queue

if ENV['RAILS_ENV'] == "test"
  Resque.inline = true
  
else
  Resque.enqueue(Jobs::Startup)
end
