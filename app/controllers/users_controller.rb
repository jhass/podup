class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit, :update, :destroy]
  
  def show
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "No such user"
      redirect_to root_path
    else
      @pods = @user.pods.accepted.active.order('score DESC')
    end
  end
  
  def update
    changes = false
    params[:user] = {} unless params[:user]
    
    unless params[:user][:name].blank?
      if current_user.update_attributes(:name => params[:user][:name])
        changes = true
      else
        current_user.reload
      end
    end
    
    unless params[:user][:email].blank?
      if current_user.update_attributes(:email => params[:user][:email])
        changes = true
      else
        current_user.reload
      end
    end
    
    unless params[:user][:public_email].blank?
      unless params[:user][:public_email].start_with?("http") or 
             params[:user][:public_email].start_with?("mailto")
        params[:user][:public_email] = "mailto:#{params[:user][:public_email]}"
      end
      
      if current_user.update_attributes(:public_email => params[:user][:public_email])
        changes = true
      end
    end
    
    if changes
      flash[:notice] = "Account details updated successfully"
      password = false
    else
      unless params[:user][:current_password].blank? or
             params[:user][:password].blank? or
             params[:user][:password_confirmation].blank?
        if current_user.update_with_password(params[:user])
          flash[:notice] = "Password changed successfuly"
          password = true
        end
      else
        flash[:error] = "Password change failed"
        password = false
      end
    end
    
    redirect_to password ? new_user_session_path : edit_user_path
  end
end
