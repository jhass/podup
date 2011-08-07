require 'spec_helper'

describe PodsController do

  describe "#index" do
    context 'user is logged out'do
      it 'succeds' do
        get :index
        response.should be_success
      end
    end
    
    context 'user is logged in' do
      before do
        @user = Factory :user
        sign_in :user, @user
      end
      
      it 'succeds' do
        get :index
        response.should be_success
      end
    end
    
    it 'shows accepted pods' do
      accepted_pod = Factory :accepted_pod
      
      get :index
      
      assigns(:pods).include?(accepted_pod).should be_true
    end
    
    it 'hides not accepted pods' do
      not_accepted_pod = Factory :pod
      
      get :index
      
      assigns(:pods).include?(not_accepted_pod).should be_false
    end
    
    it 'shows active pods' do
      active_pod = Factory :active_pod
      
      get :index
      
      assigns(:pods).include?(active_pod).should be_true
    end
    
    it 'hides inactive pods' do
      inactive_pod = Factory :inactive_pod
      
      get :index
      
      assigns(:pods).include?(inactive_pod).should be_false
    end
    
    it 'orders the pods descending by score' do
      pods = [Factory.create(:accepted_pod, :score => 100.1),
              Factory.create(:accepted_pod, :score => 90.5),
              Factory.create(:accepted_pod, :score => 80.32)]
      
      get :index
      
      assigns(:pods).should == pods
    end
  end
end
