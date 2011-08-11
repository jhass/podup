require 'spec_helper'

describe CountriesController do
  let(:user) { Factory :user }
  let(:location) { Location.first }
  
  describe  '#index' do
    context 'when user is logged out' do
      it 'succeeds' do
        get :index
        
        response.should be_success
      end
    end
    
    context 'when user is logged in' do
      before do
        sign_in :user, user
      end
      
      it 'succeeds' do
        get :index
        
        response.should be_success
      end
    end
    
    it 'assigns some locations if there any active and accepted pods' do
      Factory :active_pod
      
      get :index
      
      assigns(:locations).should be_present
    end
    
    it 'gathers all locations from accepted and active pods' do
      locations = Location.limit(5).all
      5.times do |n|
        Factory :active_pod, :location => locations[n]
      end
      
      get :index
      
      locations.each do |location|
        assigns(:locations).should include location
      end
    end
    
    it 'excludes duplicates' do
      3.times do
        Factory :active_pod, :location => location
      end
      
      get :index
      
      assigns(:locations).size.should == 1
    end
    
    it 'excludes locations from unaccepted pods' do
      Factory :unaccepted_pod, :location => location
      
      get :index
      
      assigns(:locations).should_not include location
    end
    
    it 'excludes locations from inactive pods' do
      Factory :inactive_pod, :location => location
      
      get :index
      
      assigns(:locations).should_not include location
    end
    
    it 'sorts locations by the downcased country name' do
      locations = [Factory(:location, :name => "A-country"),
                   Factory(:location, :name => "b-country"),
                   Factory(:location, :name => "C-country"),
                   Factory(:location, :name => "d-country")]
      locations.each do |location|
        Factory :active_pod, :location => location
      end
      
      get :index
      
      assigns(:locations).should == locations
    end
  end
end
