require File.join(Rails.root, 'lib', 'url.rb')

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
      redirect_to pods_path
    end
  end
  
  def new
    @pod = Pod.new
  end
  
  def create
    success = false
    unless needed_params_present?
      flash[:error] = "All fields are required"
    else
      if uri = WebURL.parse(params[:pod][:url])
        if Pod.where(:name => params[:pod][:name]).exists?
          flash[:error] = "Name already used"
        elsif Pod.where(:url => uri.to_s).exists?
          flash[:error] = "Pod already submitted"
        elsif params[:pod][:location].blank? || Country.new(params[:pod][:location].upcase).data.blank?
          flash[:error] = "The given location is invalid"
        else
          location = Location.from_host(uri.host)
          if !location || location.code != params[:pod][:location]
            location = Location.create(:code => params[:pod][:location].downcase)
          end
          pod = Pod.create(:name => params[:pod][:name], :url => uri.to_s,
                           :location => location, :owner => current_user)
          flash[:notice] = "You'll be notified when your pod is accepted"
          success = true
        end
      else
        flash[:error] = "The given URL is invalid"
      end
    end
    
    if success
      redirect_to  pods_path
    else
      @pod = Pod.new unless params[:pod]
      @pod ||= Pod.new(:name => params[:pod][:name], :url => params[:pod][:url])
      render 'pods/new'
    end
  end
  
  def update
    unless needed_params_present?
      flash[:error] = "All fields are required"
      redirect_to pod_path(:id => params[:id])
    else
      begin
        pod = Pod.find(params[:id])
        if uri = WebURL.parse(params[:pod][:url])
          if params[:pod][:name] != pod.name and Pod.where(:name => params[:pod][:name]).exists?
            flash[:error] = "Name already submitted"
          elsif params[:pod][:url] != pod.url and Pod.where(:url => params[:pod][:url]).exists?
            flash[:error] = "There's another pod with that URL submitted"
          elsif params[:pod][:location].blank? || Country.new(params[:pod][:location].upcase).data.blank?
            flash[:error] = "The given location is invalid"
          else
            #TODO: resque job, unaccept pod
            location = Location.from_code(params[:pod][:location])
            location ||= Location.from_host(uri.host)
            
            pod.update_attributes(params[:pod].merge(:location => location))
            flash[:notice] = "You'll be notified when the changes are accepted"
          end
        else
          flash[:error] = "The given URL is invalid"
        end
      rescue ActiveRedord::RecordNotFound
        flash[:error] = "Pod not found"
        redirect_to pods_path
      else
        redirect_to pod_path(pod)
      end
    end
  end
  
  def switch_maintenance
    begin
      @pod = Pod.find(params[:pod_id])
      if current_user.owns?(@pod)
        if @pod.maintenance?
          @pod.disable_maintenance!
          flash[:notice] = "Maintenance mode disabled"
        else
          @pod.enable_maintenance!
          flash[:notice] = "Maintenance mode enabled"
        end
        success = true
      else
        flash[:error] = "Not allowed"
        success = false
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Pod not found"
      success = false
    end
    
    redirect_to success ? pod_path(@pod) : pods_path
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
