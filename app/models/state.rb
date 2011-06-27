class State < ActiveRecord::Base
  belongs_to :pod, :touch => true
  
  attr_accessible :up, :maintenance, :pod_id
  
  scope :up, where(:up => true)
  scope :down, where(:up => false, :maintenance => false)
  scope :maintenance, where(:maintenance => true)
end
