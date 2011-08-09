source 'http://rubygems.org'


# standard stuff
gem 'rails', '3.0.3'
gem 'mysql2', '0.2.6'
gem 'thin'
gem 'nokogiri'
gem 'haml-rails'
gem 'sass'
gem 'jquery-rails'

# http action
gem 'faraday'
gem 'faraday-stack'

# location
gem 'geoip'
gem 'countries'

# configuration
gem 'settingslogic'

# authentication
gem 'devise'


# background processing
gem 'resque'
gem 'resque-scheduler'


# bugfixes
gem 'require_relative' # linecache
gem 'rake', '0.8.7' # rake dsl
gem 'SystemTimer', '1.2.1', :platforms => :ruby_18 # because resque likes it so much


group :development, :test do
  gem 'ruby-debug', :platforms => :mri_18
  gem 'ruby-debug19', :platforms => :ruby_19
  gem 'linecache', :platforms => :ruby_18
  gem 'linecache19', :platforms => :ruby_19
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end
