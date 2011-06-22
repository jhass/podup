class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit, :update, :destroy]
  def update
    changes = false
    params[:user] = {} unless params[:user]
    params[:user].delete(:email) if params[:user][:email].blank?
    if params[:user][:name]
      if current_user.update_attributes(:name => params[:user][:name])
        changes = true
      end
    end
    if params[:user][:email]
      if current_user.update_attributes(:email => params[:user][:email])
        changes = true
      end
    end
    
    if changes
      flash[:notice] = "Account details updated successfully"
      password = false
    else
      params[:user].delete(:current_password) if params[:user][:current_password].blank?
      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password_confirmation].blank?
      
      if params[:user][:current_password] and params[:user][:password] and params[:user][:password_confirmation]
        if current_user.update_with_password(params[:user])
          flash[:notice] = "Password changed successfuly"
          password = true
        else
          flash[:error] = "Password change failed"
          password = false
        end
      end
    end
    
    redirect_to password ? new_user_session_path : edit_user_path
  end
end
