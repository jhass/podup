require File.join(Rails.root, 'lib/geocoder')

Geocoder::Configuration.lookup = :nominatim

Geocoder::Configuration.cache = Redis.new
