module Geocoder
  class Configuration
    def self.everything_is_an_ip
      defined?(@@everything_is_an_ip) && @@everything_is_an_ip
    end
    
    def self.everything_is_an_ip=(obj)
      @@everything_is_an_ip = obj
    end
  end
  
  module Model
    module ActiveRecord
      def geocoded_by_ip(address_attr, options = {}, &block)
        was_everything_is_an_ip = Configuration.everything_is_an_ip
        Configuration.everything_is_an_ip = true
        
        geocoded_by(address_attr, options = {}, &block)
        
        Configuration.everything_is_an_ip = was_everything_is_an_ip if was_everything_is_an_ip
      end
    end
  end
  
  def search_ip(query)
    lookup = get_lookup(ip_lookups.first)
    lookup.search(query)
  end
  
  private
  def ip_address?
    Configuration.everything_is_an_ip || super
  end
end
