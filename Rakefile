# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
begin
  require File.expand_path('../config/environment', __FILE__)
rescue Mysql2::Error => e
  raise unless e.to_s.start_with?("Unknown database")
end
require 'rake'

require 'resque/tasks'
require 'resque_scheduler/tasks'

Podup::Application.load_tasks
