require 'geoip'

class Location < ActiveRecord::Base
  has_many :pods
  
  attr_accessible :name, :code, :flag
  
  def flag_path
    if self.flag
      "flags/#{self.flag}"
    else
      "icons/unknown.png"
    end
  end
  
  def self.from_host(host)
    begin
      country = geoip.country(host)
    rescue SocketError
      country = false
    end
    if country
      unless location = Location.where(:code => country.country_code2).first
        unless location = Location.where(:code => country.country_code3).first
          if country.to_hash.has_key?(:country_code2)
            code = country.country_code2
          else
            code = country.country.code3
          end
          location = Location.new(:code => code, :name => country.country_name)
        end
      end
    else
      location = false
    end
    location
  end
  
  private
  def self.geoip
    @@geoip ||= GeoIP.new(Settings.geoip[:country_db])
  end
end
