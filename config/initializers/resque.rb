Dir[File.join(Rails.root, 'app', 'models', 'jobs', '*.rb')].each { |file| require file }

require 'resque'
require 'resque_scheduler'

Resque.reset_delayed_queue
r
Pod.accepted.each do |pod|
  pod.enqueue!
end
