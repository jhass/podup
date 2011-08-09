Dir[File.join(Rails.root, 'app', 'models', 'jobs', '*.rb')].each { |file| require file }

require 'resque'
require 'resque_scheduler'

Resque.reset_delayed_queue

if ENV['RAILS_ENV'] == "test"
  Resque.inline = true
else
  Resque.enqueue(Job::Startup)
end
