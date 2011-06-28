Faraday.default_connection = Faraday::Connection.new( :ssl => {:ca_file => Settings.faraday[:ca_file]}, :timeout => Settings.faraday[:timeout] ) do |b|
  b.use FaradayStack::FollowRedirects
  b.adapter Faraday.default_adapter
end
