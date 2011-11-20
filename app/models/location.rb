class Location < ActiveRecord::Base
  has_many :pods
  
  attr_accessible :name, :code, :flag, :latitude, :longitude
  
  
  geocoded_by_ip :host
  
  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code, :latitude, :longitude
  
  after_validation :geocode, :if => lambda { self.host }
  
  scope :countries, where(:latitude => nil, :longitude => nil)
  
  def flag_path
    if self.flag
      "flags/#{self.flag}"
    else
      "icons/unknown.png"
    end
  end
  
  def host
    self.pods.first ? self.pods.first.domain : false
  end
  
  def self.from_code(code)
    location = Location.where(:code => code).first
    return location if location.present?
    country = Country.new(code.upcase)
    return nil if country.data.blank?
    Location.create(:code => code.downcase,
                    :name => country.name,
                    :flag => existing_flag_or_nil(code),
                    :longitude => normalize_coordinate(country.longitude),
                    :latitude => normalize_coordinate(country.latitude))
  end
  
  def self.from_host(host)
    begin
      result = Geocoder.search_ip(host).first
      if result
        location = Location.where(:code => result.country_code.downcase).first
        location ||= Location.create(:code => result.country_code.downcase, 
                                     :name => result.country,
                                     :flag => existing_flag_or_nil(result.country_code),
                                     :longitude => result.longitude,
                                     :latitude => result.latitude)
      end
    rescue SocketError
    end
  end
  
  private
  
  def self.existing_flag_or_nil(code)
    flag = File.join(Rails.root, "app/assets/images/flags/#{code.downcase}.png")
    (File.exists?(flag)) ? "#{code.downcase}.png" : nil
  end
  
  def self.normalize_coordinate(coordinate)
    coordinate.split(" ").take(2).join(".").to_f
  end
end
