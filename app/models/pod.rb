class Pod < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id
  has_many :statuses
  belongs_to :location
  
  validates_presence_of :name, :url, :location, :owner
  
  attr_accessible :name, :score, :url, :location, :owner

  def reliability
    100.0
  end
  
  def stars
    5
  end
  
  def score
    100.123
  end
end
