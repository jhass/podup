class Pod < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id
  has_many :statuses
  belongs_to :location
  
  validates_presence_of :name, :url, :location, :owner
  
  attr_accessible :name, :score, :url, :location, :owner, :maintenance, :accepted
  
  scope :accepted, where(:accepted => true)
  scope :active, where('maintenance != NULL AND maintenance != ? AND maintenance < ?', Time.at(0), Time.now-Settings[:inactive])

  def reliability
    100.0
  end
  
  def stars
    5
  end
  
  def score
    100.123
  end
  
  def maintenance?
    if self.maintenance and self.maintenance < Time.now and self.maintenance != Time.at(0)
      true
    else
      false
    end
  end

  def accepted?
    self.accepted
  end

  def enable_maintenance
    self.update_attributes(:maintenance => Time.now)
  end
  
  def disable_maintenance
    self.update_attributes(:maintenance => nil)
  end
end
