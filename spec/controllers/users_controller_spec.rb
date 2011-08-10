require 'spec_helper'

describe UsersController do
  let(:user) { Factory :user }
  
  describe '#show' do
    context  'with user logged out' do
      it 'succeeds' do
        get :show, :id => user.id
        
        response.should be_success
      end
    end
    
    context 'with user logged in' do
      before do
        sign_in :user, user
      end
      
      it 'succeeds' do
        get :show, :id => user.id
        
        response.should be_success
      end
    end
    
    context 'for a deleted user' do
      before do
        user = Factory :user
        @user_id = user.id
        user.destroy
      end
      
      it 'redirects to the start page' do
        get :show, :id => @user_id
        
        response.should redirect_to root_path
      end
      
      it 'should give the user an error message' do
        get :show, :id => @user_id
        
        flash[:error].should be_present
      end
    end
    
    it 'should assign the correct user' do
      get :show, :id => user.id
      
      assigns(:user).should == user
    end
    
    it 'should not assign pods from another user' do
      pod = Factory :accepted_pod
      
      get :show, :id => user.id
      
      assigns(:pods).should_not =~ pod
    end
    
    context 'for an user with some pods' do
      it 'should assign accepted pods' do
        pod = Factory :accepted_pod, :owner => user
        
        get :show, :id => user.id
        
        assigns(:pods).should include pod
      end
      
      it 'should not assing unaccepted pods' do
        pod = Factory :unaccepted_pod, :owner => user
        
        get :show, :id => user.id
        
        assigns(:pods).should_not include pod
      end
      
      it 'should assign active pods' do
        pod = Factory :active_pod, :owner => user
        
        get :show, :id => user.id
        
        assigns(:pods).should include pod
      end
      
      it 'should not assign inactive pods' do
        pod = Factory :inactive_pod, :owner => user
        
        get :show, :id => user.id
        
        assigns(:pods).should_not include pod
      end
    end
  end
  
  describe '#update' do
    context 'with user logged out' do
      it 'should redirect to the user sign in page' do
        put :update, :id => 'dummy'
        
        response.should redirect_to user_session_path
      end
    end
    
    context 'with user logged in' do
      before do
        sign_in :user, user
      end
      
      context 'when changing the passsword' do
        let(:good_params) { { :id => user.id,
                              :user => { :current_password => '123456',
                                         :password => '654321',
                                         :password_confirmation => '654321' 
                                       }
                            } }
        
        it 'updates the password with good params' do
          put :update, good_params
          
          user.reload
          user.valid_password?(good_params[:user][:password]).should be_true
        end
        
        it 'redirects the user to the sign in page on success' do
          put :update, good_params
          
          response.should redirect_to user_session_path
        end
        
        it 'calls #update_with_password on the current_user object' do
          controller.stub!(:current_user).and_return(user)
          args = {'current_password' => good_params[:user][:current_password],
                  'password' => good_params[:user][:password],
                  'password_confirmation' => good_params[:user][:password_confirmation] }
          
          user.should_receive(:update_with_password).with(args).and_return(true)
          
          put :update, good_params
        end
        
        it 'redirects to the edit user page when the password is not changed' do
          put :update, :id => user.id, :user => { :password => '654231' }
          
          response.should redirect_to edit_user_path
        end
        
        it 'informs the user about a successfully changed password' do
          put :update, good_params
          
          flash[:notice].should be_present
        end
        
        it 'informs the user about a failed password change' do
          put :update, :id => user.id, :user => { :password => '654321' }
          
          flash[:error].should be_present
        end
        
        it 'ignores the password change if there are other changes' do
          put :update, :id => user.id,
                       :user => good_params[:user].merge({:name => "Foobar"})
          
          user.reload
          user.valid_password?(good_params[:user][:password]).should_not be_true
        end
        
        it 'verifies that the current password field is set' do
          put :update, :id => user.id,
                       :user => { :password => good_params[:user][:password],
                                  :password_confirmation => good_params[:user][:password_confirmation] }
          
          user.reload
          user.valid_password?(good_params[:user][:password]).should_not be_true
        end
        
        it 'validates the current password field' do
          put :update, :id => user.id,
                       :user => { :current_password => '654321',
                                  :password => good_params[:user][:password],
                                  :password_confirmation => good_params[:user][:password_confirmation] }
          
          user.reload
          user.valid_password?(good_params[:user][:password]).should_not be_true
        end
        
        it 'verifies that the password field is set' do
          put :update, :id => user.id,
                       :user => { :current_password => good_params[:user][:current_password],
                                  :password_confirmation => good_params[:user][:password_confirmation] }
          
          user.reload
          user.valid_password?(good_params[:user][:password]).should_not be_true
        end
        
        it 'verifies that the password confirmation field is set' do
          put :update, :id => user.id,
                       :user => { :current_password => good_params[:user][:current_password],
                                  :password => good_params[:user][:password] }
          
          user.reload
          user.valid_password?(good_params[:user][:password]).should_not be_true
        end
        
        it 'verifies that the password and the password confirmation field are the same' do
          put :update, :id => user.id,
                       :user => { :current_password => good_params[:user][:current_password],
                                  :password => good_params[:user][:password],
                                  :password_confirmation => "#{good_params[:user][:password_confirmation]}_wrong" }
          
          user.reload
          user.valid_password?(good_params[:user][:password]).should_not be_true
        end
      end
      
      context 'when updating other informations' do
        it 'updates the name attribute if it is given' do
          put :update, :id => user.id, :user => { :name => "Foo Bar" }
          
          user.reload
          user.name.should == "Foo Bar"
        end
        
        it 'updates the email attribute if it is given' do
          put :update, :id => user.id, :user => { :email => "example@example.org" }
          
          user.reload
          user.email.should == "example@example.org"
        end
        
        it 'validates the email attribute if it is given' do
          put :update, :id => user.id, :user => { :email => "thats not an email" }
          
          user.reload
          user.email.should_not == "thats not an email"
        end
        
        it 'updates the public_email attribute if it is given' do
          put :update, :id => user.id, :user => { :public_email => "mailto:example@example.org" }
          
          user.reload
          user.public_email.should == "mailto:example@example.org"
        end
        
        it 'allows an url in the public_email attribute' do
          put :update, :id => user.id, :user => { :public_email => "http://example.org" }
          
          user.reload
          user.public_email.should == "http://example.org"
          
        end
        
        it 'prepends a non url in the public_email attribute with mailto:' do
          put :update, :id => user.id, :user => { :public_email => "example@example.org" }
          
          user.reload
          user.public_email.should == "mailto:example@example.org"
        end
        
        it 'does not prepend the public_email attributes value with mailto: if it is blank' do
          expect {
            put :update, :id => user.id, :user => { :public_email => "  " }
          }.to_not change(user, :public_email)
        end
        
        it 'updates the other attributes if the email attribute is invalid' do
          put :update, :id => user.id,
                       :user => { :name => "Foo Bar",
                                  :email =>  "i'm not an email",
                                  :public_email => "mailto:example@example.org" }
          
          user.reload
          user.name.should == "Foo Bar"
          user.email.should_not == "i'm not an email"
          user.public_email.should == "mailto:example@example.org"
        end
        
        it 'informs the user about applied changes' do
          put :update, :id => user.id,
                       :user => { :name => "Foo Bar",
                                  :email =>  "example@example.org",
                                  :public_email => "mailto:example@example.org" }
          
          flash[:notice].should be_present
        end
        
        it 'redirects to the edit_user_path' do
          put :update, :id => user.id,
                       :user => { :name => "Foo Bar",
                                  :email =>  "example@example.org",
                                  :public_email => "mailto:example@example.org" }
          
          response.should redirect_to edit_user_path
        end
      end
    end
  end
end
