Geocoder::Configuration.lookup = :nominatim

Geocoder::Configuration.cache = Redis.new

require File.join(Rails.root, 'lib/geocoder')
