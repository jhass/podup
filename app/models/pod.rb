class Pod < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :statuses
  belongs_to :location
  
  attr_accessible :name, :score

  def reliability
    100.0
  end
  
  def stars
    5
  end
end
