source 'http://rubygems.org'


# standard stuff
gem 'rails', '~> 3.1.1'
gem 'mysql2', '~> 0.3.10'
gem 'thin'
gem 'nokogiri'
gem 'haml-rails'
gem 'jquery-rails'
gem 'json'


# http action
gem 'faraday'
gem 'faraday-stack'

# location
gem 'countries'
gem 'geocoder', '1.0.5'

# configuration
gem 'settingslogic'

# authentication
gem 'devise'
gem 'diaspora-client', :git => 'git://github.com/diaspora/diaspora-client.git'


# background processing
gem 'resque'
gem 'resque-scheduler'


# bugfixes
gem 'require_relative' # linecache
gem 'SystemTimer', '1.2.3', :platforms => :ruby_18 # because resque likes it so much


group :development do
  # Assets
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  
  # Debug
  gem 'ruby-debug', :platforms => :mri_18
  gem 'ruby-debug19', :platforms => :ruby_19
  gem 'linecache', :platforms => :ruby_18
  gem 'linecache19', :platforms => :ruby_19
end

group :test, :development do
  # Specs
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end
