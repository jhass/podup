require 'uri'
class PodsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  def index
    @pods = Pod.order('score DESC')
  end
  
  def own
    @pods = Pod.where(:owner_id => current_user).order('score DESC')
    render :index
  end
  
  def create
    success = false
    if params[:pod].blank? or params[:pod][:name].blank? or params[:pod][:url].blank? or params[:pod][:location].blank?
      flash[:error] = "All fields are required"
    else
      if uri = URI.parse(params[:pod][:url])
        if Pod.where(:name => params[:pod][:name]).first
          flash[:error] = "Name already used"
        elsif Pod.where(:url => params[:pod][:url]).first
          flash[:error] = "Pod already submitted"
        elsif location = Location.where(:code => params[:pod][:location].downcase).first
          #TODO: resque job
          Pod.create!(:name => params[:pod][:name], :url => uri.to_s, :location => location,
                      :owner => current_user)
          flash[:notice] = "You'll be notified when your pod is accepted"
          success = true
        else
          flash[:error] = "The given location is invalid"
        end
      else
        flash[:error] = "The given URL is invalid"
      end
    end
    
    redirect_to success ? pods_path : new_user_pod_path
  end
end
