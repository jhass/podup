require File.join(Rails.root, 'lib', 'url.rb')

class Pod < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id
  has_many :states
  belongs_to :location
  
  validates_presence_of :name, :url, :location, :owner
  validates_uniqueness_of :name, :url
  validates_format_of :url, :with => WebURL.regex
  
  attr_accessible :name, :score, :url, :location, :owner, :maintenance, 
                  :accepted, :version, :updated, :reliability, :upsince
  
  after_create :enqueue_approval!
  
  scope :accepted, where(:accepted => true)
  scope :active, where('pods.maintenance IS NULL OR pods.maintenance = ? OR pods.maintenance > ?', Time.at(0), Time.now-Settings[:inactive])
  
  
  #Atributes
  
  def uri
    @uri ||= WebURL.parse(self.url)
  end
  
  def version
    version = 'n/a'
    if self[:version].blank?
      if site && site.header.key?('x-git-revision')
        version = site.header['x-git-revision']
        self.update_attributes(:version => version)
      end
    else
      version = self[:version]
    end
    version
  end
  
  def updated
    updated = Time.at(0)
    if self[:updated].blank? || self[:updated] == Time.at(0)
      if site && site.header.key?('x-git-update')
        now = Time.now
        parsed = Time.parse(site.header['x-git-update'], now)
        unless parsed == now
          updated = parsed
          self.update_attributes(:updated => updated)
        end
      end
    else
      updated = self[:updated]
    end
    updated
  end
  
  def stars
    case self.reliability
      when nil then 0
      when 0 then 0
      when 1..40 then 1
      when 40..60 then 2
      when 60..80 then 3
      when 80..95 then 4
      else 5
    end
  end
  
  def reliability
    self[:reliability] || 0.0
  end
  
  def score
    self[:score] || 0.0
  end
  
  # Checks
  
  def is_modern?
    return false if self.version == 'n/a'
    return false if self.updated == Time.at(0)
    return true
  end
  
  def is_up?(save_state=true)
    if self.maintenance?
      if save_state
        State.create!(:up => false, :maintenance => true, :pod_id => self.id)
      end
      return false
    end
    up = site ? true : false
    if save_state
      State.create!(:up => up, :maintenance => false, :pod_id => self.id)
    end
    up
  end
  
  def maintenance?
    if self.maintenance and self.maintenance < Time.now and self.maintenance != Time.at(0)
      true
    else
      false
    end
  end
  
  def accepted?
    self.accepted
  end
  
  
  # Stats
  
  def compute_reliability!
    if self.states.count > 0
      reliability = (self.states.up.count.to_f/self.states.count.to_f)*100
    else
      reliability = 0.0
    end
    self.update_attributes(:reliability => reliability)
  end
  
  
  def compute_score!
    if self.states.count > 0
      score = ((self.states.up.count.to_f*90 + self.states.down.count.to_f*20)/self.states.count.to_f)
      score += ((self.states.count.to_f-self.states.maintenance.count.to_f)/self.states.count.to_f)+5
    else
      score = 70
    end
    score -= 10.0 unless self.is_modern?
    unless self.upsince
      score -= 10
    else
      uptime = Time.now-self.upsince
      score += uptime/(60*60*24*7)
    end
    self.update_attributes(:score => score)
  end
  
  def compute_uptime!
    if down = self.states.down.order("id DESC").limit(1).first
      oldest_up = self.states.up.where("id > ?", down.id).order("id ASC").limit(1).first
    else
      oldest_up = self.states.up.order("id ASC").limit(1).first
    end
    
    if oldest_up
      self.update_attributes(:upsince =>  oldest_up.created_at)
    else
      self.update_attributes(:upsince => nil)
    end
  end
  
  
  # Actions
  
  def enable_maintenance
    self.update_attributes(:maintenance => Time.now)
  end
  
  def disable_maintenance
    self.update_attributes(:maintenance => nil)
  end
  
  def enqueue!
    Resque.enqueue_in(Settings[:check_every], Job::Check, self.id)
  end
  
  def enqueue_approval!
    Resque.enqueue(Job::Approval, self.id)
  end
  
  private
  
  
  # Helper
  
  def site
    begin
      @site ||= Faraday.get(self.uri+'/users/sign_in')
    rescue Exception => e
      #puts e
      #TODO log, finer Exception catching
      false
    end
  end
end
