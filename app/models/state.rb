class State < ActiveRecord::Base
  belongs_to :pod, :touch => true
  
  attr_accessible :up, :maintenance, :pod_id, :created_at
  
  validates_presence_of :pod
  validates_inclusion_of :up, :maintenance, :in => [true, false]
  
  scope :up, where(:up => true)
  scope :down, where(:up => false, :maintenance => false)
  scope :maintenance, where(:maintenance => true)
  
  def up?
    self[:up]
  end
end
