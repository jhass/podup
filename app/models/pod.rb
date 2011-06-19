class Pod < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :statuses
  has_one :location
end
