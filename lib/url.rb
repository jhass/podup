require 'uri'

class WebURL
  def self.regex
    # from http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    /(?i)\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/
  end
  
  def self.valid?(url)
    return false unless url.is_a?(String)
    return url =~ regex
  end
  
  def self.parse(url)
    return false unless valid?(url)
    return URI.parse(url)
  end
end
