class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :pods, :foreign_key => :owner_id
  
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :public_email
  
  def name
    return self[:name] unless self[:name].blank?
    return self[:public_email] unless self[:public_email].blank?
    return 'unknown'
  end
  
  def owns?(pod)
    Pod.where(:owner_id => self, :id => pod).exists?
  end
  
  def contactable?
    if self.public_email and !self.public_email.blank?
      true
    else
      false
    end
  end
end
