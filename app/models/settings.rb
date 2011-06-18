require 'uri'

class Settings < Settingslogic
  source File.join(Rails.root, "config", "settings.yml")
  namespace Rails.env
  cattr_accessor :uri
  
  def self.load!
    normalize_host
  end
  
  def self.[](key)
    return self.uri if key.to_sym == :uri
    super
  end
  
  def self.[]=(key, val)
    super
    if key.to_sym == :host
      @@uri = nil
      normalize_host
    end
  end
  
  def self.normalize_host
    unless self[:host] =~ /^(https?:\/\/)/
      self[:host] = "http://#{self[:host]}"
    end
    unless self[:host] =~ /\/$/
      self[:host] = "#{self[:host]}/"
    end
  end
  
  def self.uri
    if @@uri.nil?
      begin
        @@uri = URI.parse(self[:host])
      rescue
        puts "Oh noes! An invalid host was set!"
      end
    end
    return @@uri
  end
end
