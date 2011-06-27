require 'mechanize'
Mechanize.html_parser = Nokogiri::HTML

module MechanizeHelper
  def mechanize
    @agent ||= Mechanize.new
  end
end
