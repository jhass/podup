class Location < ActiveRecord::Base
  has_many :pods
  
  attr_accessible :name, :code, :flag, :latitude, :longitude, :host
  
  
  geocoded_by :host
  
  validates_presence_of :name, :code, :latitude, :longitude
  validates_uniqueness_of :name, :code, :latitude, :longitude
  
  after_validation :geocode
  
  def flag_path
    if self.flag
      "flags/#{self.flag}"
    else
      "icons/unknown.png"
    end
  end
  
  def self.from_host(host)
    begin
      result = Geocoder.search_ip(host).first
      if result
        location = Location.where(:code => result.country_code.downcase).first
        flag = File.join(Rails.root, "app/assets/images/flags/#{result.country_code.downcase}.png")
        flag = (File.exists?(flag)) ? "#{result.country_code.downcase}.png" : nil
        location ||= Location.new(:code => result.country_code.downcase, 
                                  :name => result.country,
                                  :flag => flag,
                                  :longitude => result.longitude,
                                  :latitude => result.latitude)
      end
    rescue SocketError
    end
  end
end
