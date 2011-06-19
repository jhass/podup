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
end
