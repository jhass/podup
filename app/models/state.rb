class State < ActiveRecord::Base
  belongs_to :pod, :touch => true
  
  attr_accesible :up
end
