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
    let(:good_pod_params) { { :pod => {
                                :name => "Test pod",
                                :url => "http://test-pod.example.org",
                                :location => "de" 
                              } 
                            } 
                          }
    let(:bad_pod_params) { { :no_pod => { :foo => :bar } } }
    
    context 'with logged out user' do
      it 'redirects to the user sign in page' do
        post :create
        
        response.should redirect_to user_session_path
      end
    end
    
    context 'with logged in user' do
      before do
        sign_in :user, user
      end
      
      it 'creates a new pod on success' do
        expect {
          post :create, good_pod_params
        }.to change(Pod, :count).by(1)
      end
      
      it 'does not create a new pod with insufficient params' do
        expect {
          post :create, bad_pod_params
        }.to change(Pod, :count).by(0)
      end
      
      it 'redirects to the pods index with sufficient params' do
        post :create, good_pod_params
        
        response.should redirect_to pods_path
      end
      
      it 'redirects to the new pod form with insufficent params' do
        post :create, bad_pod_params
        
        response.should redirect_to new_pod_path
      end
      
      it 'verifies that the name fied is set' do
        expect {
          post :create, :pod => {:url => good_pod_params[:pod][:url],
                                 :location => good_pod_params[:pod][:location]}
        }.to change(Pod, :count).by(0)
      end
      
      it 'verifies that the url field is set' do
        expect {
          post :create, :pod => {:name => good_pod_params[:pod][:name],
                                 :location => good_pod_params[:pod][:location]}
        }.to change(Pod, :count).by(0)
      end
      
      it 'validates the url field' do
        expect {
          post :create, :pod => {:name => good_pod_params[:pod][:name],
                                  :url => "tritratralala",
                                  :location => good_pod_params[:pod][:location]}
        }.to change(Pod, :count).by(0)
      end
      
      it 'verifies that the location field is set' do
        expect {
          post :create, :pod => {:name => good_pod_params[:pod][:name],
                                 :url => good_pod_params[:pod][:url]}
        }.to change(Pod, :count).by(0)
      end
      
      it 'validates the location field' do
        expect {
          post :create, :pod => {:name => good_pod_params[:pod][:name],
                                 :url => good_pod_params[:pod][:url],
                                 :location => "Absurdistan"}
        }.to change(Pod, :count).by(0)
      end
      
      it 'does not allow two pods with the same name' do
        expect {
          post :create, good_pod_params
          post :create, :pod => {:name => good_pod_params[:pod][:name],
                                  :url => "http://test-pod2.example.org",
                                  :location => good_pod_params[:pod][:location]}
        }.to change(Pod, :count).by(1)
      end
      
      it 'does not allow two pods with the same url' do
        expect {
          post :create, good_pod_params
          post :create, :pod => {:name => "Test pod 2",
                                  :url => good_pod_params[:pod][:url],
                                  :location => good_pod_params[:pod][:location]}
        }.to change(Pod, :count).by(1)
      end
      
      it 'informs the user about a failure' do
        post :create, bad_pod_params
        
        flash[:error].should be_present
      end
      
      it 'informs the user about the success' do
        post :create, good_pod_params
        
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
    
    context 'with logged in user' do
      before do
        sign_in :user, user
        @pod = Factory :pod
        
        @pod_before = {:name => @pod.name, :url => @pod.url.to_s,
                       :location => @pod.location.code }
        
        @good_pod_params = { :id => @pod.id,
                             :pod => {
                               :name => "Test pod",
                               :url => "http://test-pod.example.org",
                               :location => "de"
                             }
                           }
        
        @bad_pod_params = { :id => @pod.id, :no_pod => { :foo => :bar } }
      end
      
      it 'updates the pod on success' do
        put :update, @good_pod_params
        
        @pod.reload
        @pod.name.should == @good_pod_params[:pod][:name]
        @pod.url.to_s.should == @good_pod_params[:pod][:url]
        @pod.location.code.should == @good_pod_params[:pod][:location]
      end
      
      it 'does not update the pod with insufficient params' do
        put :update, @bad_pod_params
        
        @pod.reload
        @pod.name.should == @pod_before[:name]
        @pod.url.to_s.should == @pod_before[:url]
        @pod.location.code.should == @pod_before[:location]
      end
      
      it 'redirects to the pods show page on success' do
        put :update, @good_pod_params
        
        response.should redirect_to pod_path(@pod)
      end
      
      it 'redirects to the pods show page on failure' do
        put :update, @bad_pod_params
        
        response.should redirect_to pod_path(@pod)
      end
      
      it 'verifies that the name field is set' do
        put :update, :id => @pod.id,
                     :pod => { :url => @good_pod_params[:pod][:url],
                               :location => @good_pod_params[:pod][:location] }
        
        @pod.reload
        @pod.name.should == @pod_before[:name]
        @pod.url.to_s.should == @pod_before[:url]
        @pod.location.code.should == @pod_before[:location]
      end
      
      it 'verifies that the url field is set' do
        put :update, :id => @pod.id,
                     :pod => { :name => @good_pod_params[:pod][:name],
                               :location => @good_pod_params[:pod][:location] }
        
        @pod.reload
        @pod.name.should == @pod_before[:name]
        @pod.url.to_s.should == @pod_before[:url]
        @pod.location.code.should == @pod_before[:location]
      end
      
      it 'validates the url field' do
        put :update, :id => @pod.id,
                     :pod => { :name => @good_pod_params[:pod][:name],
                               :url => "tritratralala",
                               :location => @good_pod_params[:pod][:location] }
        
        @pod.reload
        @pod.name.should == @pod_before[:name]
        @pod.url.to_s.should == @pod_before[:url]
        @pod.location.code.should == @pod_before[:location]
      end
      
      it 'verifies that the location field is set' do
        put :update, :id => @pod.id,
                     :pod => { :name => @good_pod_params[:pod][:name],
                               :url => @good_pod_params[:pod][:url] }
        
        @pod.reload
        @pod.name.should == @pod_before[:name]
        @pod.url.to_s.should == @pod_before[:url]
        @pod.location.code.should == @pod_before[:location]
      end
      
      it 'validates the location field' do
        put :update, :id => @pod.id,
                     :pod => { :name => @good_pod_params[:pod][:name],
                               :url => @good_pod_params[:pod][:url],
                               :location => "Absurdistan" }
        
        @pod.reload
        @pod.name.should == @pod_before[:name]
        @pod.url.to_s.should == @pod_before[:url]
        @pod.location.code.should == @pod_before[:location]
      end
      
      it 'does not allow two pods with the same name' do
        Factory :pod, :name => @good_pod_params[:pod][:name]
        
        put :update, @good_pod_params
        
        @pod.reload
        @pod.name.should == @pod_before[:name]
        @pod.url.to_s.should == @pod_before[:url]
        @pod.location.code.should == @pod_before[:location]
      end
      
      it 'does not allow two pods with the same url' do
        Factory :pod, :url => @good_pod_params[:pod][:url]
        
        put :update, @good_pod_params
        
        @pod.reload
        @pod.name.should == @pod_before[:name]
        @pod.url.to_s.should == @pod_before[:url]
        @pod.location.code.should == @pod_before[:location]
      end
      
      it 'informs the user about a failure' do
        put :update, @bad_pod_params
        
        flash[:error].should be_present
      end
      
      it 'informs the user about the success' do
        put :update, @good_pod_params
        
        flash[:notice].should be_present
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
              @pod.enable_maintenance!
            end
            
            it 'should turn the maintenance mode off' do
              get :switch_maintenance, :pod_id => @pod.id
              
              
              @pod.reload.maintenance?.should be_false
            end
          end
        
          context 'with disabled maintenance mode' do
            before do
              @pod.disable_maintenance!
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
