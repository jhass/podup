# from https://github.com/diaspora/diaspora/blob/master/config/initializers/check_session_secret.rb
unless File.exists?( File.join(Rails.root, 'config', 'initializers', 'secret_token.rb'))
  `rake generate:secret_token`
   require  File.join(Rails.root, 'config', 'initializers', 'secret_token.rb')
end
