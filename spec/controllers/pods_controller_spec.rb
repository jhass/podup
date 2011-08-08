require 'spec_helper'

describe PodsController do
  let(:user) { Factory :user }
  
  describe "#index" do
    context 'with logged out user'do
      it 'succeeds' do
        get :index
        response.should be_success
      end
    end
    
    context 'with logged in user' do
      before do
        sign_in :user, user
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
    context 'with logged out user' do
      it 'redirects to the sign in page' do
        get :own
        
        response.should redirect_to user_session_path
      end
    end
    
    context 'with logged in user' do
      before do
        sign_in :user, user
      end
      
      it 'succeeds' do
        get :own
        
        response.should be_success
      end
      
      it 'shows the current users accepted pods' do
        accepted_pod = Factory :accepted_pod, :owner => user
        
        get :own
        
        assigns(:pods).include?(accepted_pod).should be_true
      end
      
      it 'shows the current users unaccepted pods' do
        unaccepted_pod = Factory :unaccepted_pod, :owner => user
        
        get :own
        
        assigns(:pods).include?(unaccepted_pod).should be_true
      end
      
      it 'shows the current users active pods' do
        active_pod = Factory :active_pod, :owner => user
        
        get :own
        
        assigns(:pods).include?(active_pod).should be_true
      end
      
      it 'shows the current users inactive pods' do
        inactive_pod = Factory :inactive_pod, :owner => user
        
        get :own
        
        assigns(:pods).include?(inactive_pod).should be_true
      end
      
      it 'only shows the current users pods' do
        another_pod = Factory :pod
        
        get :own
        
        assigns(:pods).include?(another_pod).should be_false
      end
      
      it 'orders the pods descending by score' do
        pods = [Factory(:pod, :score => 100.1, :owner => user),
                Factory(:pod, :score => 90.5, :owner => user),
                Factory(:pod, :score => 80.32, :owner => user)]
        
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
      
      it 'redirects to the pod index' do
        get :show, :id => @pod_id
        
        response.should redirect_to pods_path
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
          sign_in :user, user
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
  
  describe "#create" do
    context 'with logged out user' do
      it 'redirects to the user sign in page' do
        post :create
        
        response.should redirect_to user_session_path
      end
    end
    
    context 'with logged in user' do
      before do
        sign_in :user, user
        
        #if pod = Pod.where(:name ="Test pod").first
        #  pod.destroy
        #end
      end
      
      it 'creates a new pod' do
        expect {
          post :create, :pod => {:name => "Test pod",
                                 :url => "http://test-pod.example.org",
                                 :location => "DE"}
        }.to change(Pod, :count).by(1)
      end
      
      it 'does not create a new pod with insufficient params' do
        expect {
          post :create, :no_pod => {:foo => :bar}
        }.to change(Pod, :count).by(0)
      end
      
      it 'redirects to the pods index with sufficient params' do
        post :create, :pod => {:name => "Test pod",
                               :url => "http://test-pod.example.org",
                               :location => "DE"}
        
        response.should redirect_to pods_path
      end
      
      it 'redirects to the new pod form with insufficent params' do
        post :create, :no_pod => {:foo => :bar}
        
        response.should redirect_to new_pod_path
      end
      
      it 'verifes that the name fied is set' do
        expect {
          post :create, :pod => {:url => "http://test-pod.example.org",
                                 :location => "DE"}
        }.to change(Pod, :count).by(0)
      end
      
      it 'verifes that the url field is set' do
        expect {
          post :create, :pod => {:name => "Test pod",
                                 :location => "DE"}
        }.to change(Pod, :count).by(0)
      end
      
      it 'validates the url field' do
        expect {
          post :create, :pod => {:name => "Test pod",
                                  :url => "tritratralala",
                                  :location => "DE"}
        }.to change(Pod, :count).by(0)
      end
      
      it 'verifes that the location field is set' do
        expect {
          post :create, :pod => {:name => "Test pod",
                                 :url => "http://test-pod.example.org"}
        }.to change(Pod, :count).by(0)
      end
      
      it 'validates the location field' do
        expect {
          post :create, :pod => {:name => "Test pod",
                                 :url => "http://test-pod.example.org",
                                 :location => "Absurdistan"}
        }.to change(Pod, :count).by(0)
      end
      
      it 'does not allow two pods with the same name' do
        expect {
          post :create, :pod => {:name => "Test pod",
                                  :url => "http://test-pod.example.org",
                                  :location => "DE"}
          post :create, :pod => {:name => "Test pod",
                                  :url => "http://test-pod2.example.org",
                                  :location => "DE"}
        }.to change(Pod, :count).by(1)
      end
      
      it 'does not allow two pods with the same url' do
        expect {
          post :create, :pod => {:name => "Test pod",
                                  :url => "http://test-pod.example.org",
                                  :location => "DE"}
          post :create, :pod => {:name => "Test pod 2",
                                  :url => "http://test-pod.example.org",
                                  :location => "DE"}
        }.to change(Pod, :count).by(1)
      end
      
      it 'informs the user about a failure' do
        post :create, :no_pod => {:foo => :bar}
        
        flash[:error].should be_present
      end
      
      it 'informs the user about the success' do
        post :create, :pod => {:name => "Test pod",
                               :url => "http://test-pod.example.org",
                               :location => "DE"}
        
        flash[:notice].should be_present
      end
    end
  end
  
  describe "#update" do
    context 'withlogged out user' do
      it 'redirects to the user sign in page' do
        put :update, :id => 'dummy'
        
        response.should redirect_to user_session_path
      end
    end
  end
  
  
  describe '#switch_maintenance' do
    let(:pod) { Factory :pod }
    
    context 'with logged out user' do
      it 'redirects to the user sign in page' do
        get :switch_maintenance, :pod_id => pod.id
        
        response.should redirect_to user_session_path
      end
    end
    
    context 'with logged in user' do
      let(:user) { Factory :user }
      before do
        sign_in :user, user
      end
      
      context 'with an existing pod' do
        context 'with an pod owned by the current user' do
          before do
            @pod = Factory :pod, :owner => user
          end
          
          context 'with enabled maintenance mode' do
            before do
              @pod.enable_maintenance
            end
            
            it 'should turn the maintenance mode off' do
              get :switch_maintenance, :pod_id => @pod.id
              
              
              @pod.reload.maintenance?.should be_false
            end
          end
        
          context 'with disabled maintenance mode' do
            before do
              @pod.disable_maintenance
            end
            
            it 'should turn the maintenance mode on' do
              get :switch_maintenance, :pod_id => @pod.id
              
              @pod.reload.maintenance?.should be_true
            end
          end
          
          it 'should notify the user about its actions' do
            get :switch_maintenance, :pod_id => @pod.id
            
            flash[:notice].should be_present
          end
        end
      end
      
      context 'with a pod not owned by the current user' do
         it 'denies any changes' do
          before = pod.maintenance?
          
          get :switch_maintenance, :pod_id => pod.id
          
          pod.maintenance?.should == before
        end
        
        it 'redirects to the pod index' do
          get :switch_maintenance, :pod_id => pod.id
          
          response.should redirect_to pods_path
        end
        
        it 'should inform the user about the error' do
          get :switch_maintenance, :pod_id => pod.id
          
          flash[:error].should be_present
        end
      end
      
      context 'with a not existing pod' do
        before do
          pod = Factory :pod
          @pod_id = pod.id
          pod.destroy
        end
        
        it 'redirects back to the pods index' do
          get :switch_maintenance, :pod_id => @pod_id
          
          response.should redirect_to pods_path
        end
        
        it 'should give an error message' do
          get :switch_maintenance, :pod_id => @pod_id
          
          flash[:error].should be_present
        end
      end
    end
  end
end
