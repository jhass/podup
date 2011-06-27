class State < ActiveRecord::Base
  belongs_to :pod, :touch => true
  
  attr_accessible :up, :pod_id
  
  scope :up, where(:up => true)
  scope :down, where(:up => false)
end
