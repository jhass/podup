FactoryGirl.define do
  factory :user, :aliases => [:owner] do
    sequence(:email) {|n|  "tester#{n}@examples.org" }
    password '123456'
    password_confirmation { password }
  end


  factory :pod do
    sequence(:name) {|n| "Pod #{n}" }
    url { "http://#{name.downcase.gsub(' ', '_')}.pods.example.org" }
    location Location.first
    owner
    
    factory :accepted_pod do
      sequence(:name) {|n| "Accepted pod #{n}" }
      url { "http://#{name.downcase.gsub(' ', '_')}.pods.example.org" }
      accepted true
      
      factory :active_pod do
      end
      
      factory :inactive_pod do
        sequence(:name) {|n| "Inactive pod #{n}" }
        url { "http://#{name.downcase.gsub(' ', '_')}.pods.example.org" }
        maintenance Time.at(1)
      end
    end
    
    factory :unaccepted_pod do
    end
  end
  
  factory :state do
    maintenance false
    up true
    pod
    
    factory :maintenance_state do
      maintenance true
      up false
    end
  end
end

