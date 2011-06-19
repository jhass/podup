class Status < ActiveRecord::Base
  belongs_to :pod, :touch => true
  
end
