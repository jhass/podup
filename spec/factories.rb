FactoryGirl.define do
  factory :user, :aliases => [:owner] do
    sequence(:email) {|n|  "tester#{n}@examples.org" }
    password '123456'
    password_confirmation { password }
  end
  
  factory :location do
    sequence(:name) {|n| "Country #{n}" }
    sequence(:code) {|n| "c#{n}" }
  end
  
  factory :pod do
    sequence(:name) {|n| "Pod #{n}" }
    sequence(:url) {|n| "http://pod-#{n}.pods.example.org" }
    location { Location.first }
    owner
    
    factory :accepted_pod do
      sequence(:name) {|n| "Accepted pod #{n}" }
      accepted true
      
      factory :active_pod do
      end
      
      factory :inactive_pod do
        sequence(:name) {|n| "Inactive pod #{n}" }
        maintenance Time.at(1)
      end
    end
    
    factory :unaccepted_pod do
    end
  end
  
  factory :state do
    up false
    maintenance false
    pod
    
    factory :up_state do
      up true
      
      factory :up_maintenance_state do
        maintenance true
      end
    end
    
    factory :down_state do
      factory :maintenance_state do
        maintenance true
        
        factory :down_maintenance_state do
        end
      end
    end
  end
end

