class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :pods, :foreign_key => :owner_id
  
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  def owns?(pod)
    Pod.where(:owner_id => self, :id => pod).exists?
  end
end
