require 'spec_helper'

describe PodsController do
  
  describe "#index" do
    context 'user is logged out'do
      it 'succeeds' do
        get :index
        response.should be_success
      end
    end
    
    context 'user is logged in' do
      before do
        @user = Factory :user
        sign_in :user, @user
      end
      
      it 'succeeds' do
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
      pods = [Factory(:accepted_pod, :score => 100.1),
              Factory(:accepted_pod, :score => 90.5),
              Factory(:accepted_pod, :score => 80.32)]
      
      get :index
      
      assigns(:pods).should == pods
    end
  end
  
  describe '#own' do
    context 'user is logged out' do
      it 'redirects to the sign in page' do
        get :own
        
        response.should redirect_to user_session_path
      end
    end
    
    context 'user is logged in' do
      before do
        @user = Factory :user
        sign_in :user, @user
      end
      
      it 'succeeds' do
        get :own
        
        response.should be_success
      end
      
      it 'shows the current users accepted pods' do
        accepted_pod = Factory :accepted_pod, :owner => @user
        
        get :own
        
        assigns(:pods).include?(accepted_pod).should be_true
      end
      
      it 'shows the current users unaccepted pods' do
        unaccepted_pod = Factory :unaccepted_pod, :owner => @user
        
        get :own
        
        assigns(:pods).include?(unaccepted_pod).should be_true
      end
      
      it 'shows the current users active pods' do
        active_pod = Factory :active_pod, :owner => @user
        
        get :own
        
        assigns(:pods).include?(active_pod).should be_true
      end
      
      it 'shows the current users inactive pods' do
        inactive_pod = Factory :inactive_pod, :owner => @user
        
        get :own
        
        assigns(:pods).include?(inactive_pod).should be_true
      end
      
      it 'only shows the current users pods' do
        another_pod = Factory :pod
        
        get :own
        
        assigns(:pods).include?(another_pod).should be_false
      end
      
      it 'orders the pods descending by score' do
        pods = [Factory(:pod, :score => 100.1, :owner => @user),
                Factory(:pod, :score => 90.5, :owner => @user),
                Factory(:pod, :score => 80.32, :owner => @user)]
        
        get :own
        
        assigns(:pods).should == pods
      end
    end
  end
  
  describe '#show' do
    context 'with a not exisitng pod' do
      before do
        pod = Factory :pod
        @pod_id = pod.id
        pod.destroy
      end
      
      it 'redirects to #index' do
        get :show, :id => @pod_id
        
        response.should redirect_to :action => :index
      end
      
      it 'gives a error message to the user' do
        get :show, :id => @pod_id
        
        flash[:error].should be_present
      end
    end
    
    context 'with an existing pod' do
      before do
        @pod = Factory :pod
      end
      
      context 'user is logged out' do
        it 'succeeds' do
          get :show, :id => @pod.id
          
          response.should be_success
        end
      end
      
      context 'user is logged in' do
        before do
          @user = Factory :user
          sign_in :user, @user
        end
        
        it 'succeeds' do
          get :show, :id => @pod.id
          
          response.should be_success
        end
      end
      
      it 'assigns the right pod' do
        get :show, :id => @pod.id
        
        assigns(:pod).should == @pod
      end
      
      context 'with some states' do
        before do
          @states = []
          10.times do
            state = Factory :state, :pod => @pod
            @states << state
          end
        end
        
        it 'assigns the five most recent states' do
          get :show, :id => @pod.id
          
          assigns(:states).should == @states.reverse[0..4]
        end
        
        it 'assigns no maintenance states' do
          state = Factory :maintenance_state, :pod => @pod
          
          get :show, :id => @pod.id
          
          assigns(:states).include?(state).should be_false
        end
      end
    end
  end
end
