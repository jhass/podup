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
  
  describe '#show' do
    before do
      @pod = Factory :active_pod, :location => location
    end
    
    context 'when user is logged out' do
      it 'succeeds' do
        get :show, :id => location.id
        
        response.should be_success
      end
    end
    
    context 'when user is logged in' do
      before do
        sign_in :user, user
      end
      
      it 'succeeds' do
        get :show, :id => location.id
        
        response.should be_success
      end
    end
    
    it 'assigns the right location' do
      get :show, :id => location.id
      
      assigns(:location).should == location
    end
    
    it 'assigns active and accepted pods with that location' do
      get :show, :id => location.id
      
      assigns(:pods).should include @pod
    end
    
    it 'does not assign unaccepted pods' do
      pod = Factory :unaccepted_pod, :location => location
      
      get :show, :id => location.id
      
      assigns(:pods).should_not include pod
    end
    
    it 'does not assign inactive pods' do
      pod = Factory :inactive_pod, :location =>location
      
      get :show, :id => location.id
      
      assigns(:pods).should_not include pod
    end
    
    it 'does not assign pods from other locations' do
      pod = Factory :active_pod, :location => Factory(:location)
      
      get :show, :id => location.id
      
      assigns(:pods).should_not include pod
    end
    
    it 'orders the pods descending by score' do
      location = Factory :location
      pods = [Factory(:active_pod, :location => location, :score => 100.5),
              Factory(:active_pod, :location => location, :score => 95.8),
              Factory(:active_pod, :location => location, :score => 81.23)]
      
      get :show, :id => location.id
      
      assigns(:pods).should == pods
    end
    
    context 'with a not existing location' do
      before do
        location = Factory :location
        @location_id = location.id
        location.destroy
      end
      
      it 'redirects to the countries index page' do
        get :show, :id => @location_id
        
        response.should redirect_to countries_path
      end
      
      it 'informs the user about the failure' do
        get :show, :id => @location_id
        
        flash[:error].should be_present
      end
    end
    
    context 'with a location with no pods' do
      before do
        @location = Factory :location
      end
      
      it 'redirects to the countries index page' do
        get :show, :id => @location.id
        
        response.should redirect_to countries_path
      end
      
      it 'informs the user about the failure' do
        get :show, :id => @location.id
        
        flash[:error].should be_present
      end
    end
  end
end
