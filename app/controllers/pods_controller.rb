require 'uri'
class PodsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  def index
    @pods = Pod.accepted.active.order('score DESC')
  end
  
  def own
    @pods = current_user.pods.order('score DESC')
  end
  
  def show
    begin
      @pod = Pod.find(params[:id])
      @states = @pod.states.where(:maintenance => false).order('id DESC').limit(5)
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "No such pod"
      redirect_to :action => :index
    end
  end
  
  def create
    success = false
    unless needed_params_present?
      flash[:error] = "All fields are required"
    else
      if uri = URI.parse(params[:pod][:url])
        if Pod.where(:name => params[:pod][:name]).exists?
          flash[:error] = "Name already used"
        elsif Pod.where(:url => params[:pod][:url]).exists?
          flash[:error] = "Pod already submitted"
        elsif location = Location.where(:code => params[:pod][:location].downcase).first
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
  
  def update
    unless needed_params_present?
      flash[:error] = "All fields are required"
    else
      if uri = URI.parse(params[:pod][:url]) and pod = Pod.find(params[:id])
        if params[:pod][:name] != pod.name and Pod.where(:name => params[:pod][:name]).exists?
          flash[:error] = "Name already submitted"
        elsif params[:pod][:url] != pod.url and Pod.where(:url => params[:pod][:url]).exists?
          flash[:error] = "There's another pod with that URL submitted"
        elsif location = Location.where(:code => params[:pod][:location].downcase).first
          #TODO: resque job
          pod.update_attributes(params[:pod].merge(:location => location))
          flash[:notice] = "You'll be notified when the changes are accepted"
        else
          flash[:error] = "The given location is invalid"
        end
      else
        flash[:error] = "The given URL is invalid or there were another problem"
      end
    end
    
    redirect_to :back
  end
  
  def switch_maintenance
    if @pod = Pod.find(params[:pod_id]) and current_user.owns?(@pod)
      if @pod.maintenance?
        @pod.disable_maintenance
        flash[:notice] = "Maintenance mode disabled"
      else
        @pod.enable_maintenance
        flash[:notice] = "Maintenance mode enabled"
      end
      success = true
    else
      flash[:error] = "No such pod or not allowed"
      success = false
    end
    
    redirect_to success ? :back : :index
  end
  
  private
  def needed_params_present?
    if params[:pod].blank? or params[:pod][:name].blank? or params[:pod][:url].blank? or params[:pod][:location].blank?
      false
    else
      true
    end
  end
end
