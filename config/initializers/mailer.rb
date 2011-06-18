Podup::Application.configure do 
  config.action_mailer.default_url_options = {:host => Settings[:uri].host}
  unless Rails.env == 'test' || Settings.mailer[:enable] != true
    config.action_mailer.smtp_settings = {
      :address => Settings.mailer[:address],
      :port => Settings.mailer[:port],
      :domain => Settings.mailer[:domain],
      :authentication => Settings.mailer[:authentication],
      :user_name => Settings.mailer[:user],
      :password => Settings.mailer[:password],
      :enable_starttls_auto => Settings.mailer[:starttls_auto]
    }
  end
end
