require 'uri'

class CountriesController < ApplicationController
  
  respond_to :json, :only => [:get_code_for, :get_code_for_current_ip]
  
  def index
    @locations = Pod.accepted.active.collect { |x| x.location }
    @locations.uniq!
    @locations.sort! { |x, y| x.name.downcase <=> y.name.downcase }
  end
  
  def show
    unless @location = Location.find(params[:id])
      flash[:error] = "Couldn't find country"
      redirect :index
    else
      unless @pods = Pod.active.where(:location_id => @location.id).order('score DESC')
        flash[:error] = "Couldn't find any active pods for #{@location.name}"
        redirect :index
      end
    end
  end
  
  def get_code_for_current_ip
    ip = request.remote_ip
    ip = request.env["HTTP_X_FORWARDED_FOR"] if ip == '127.0.0.1' && request.env.has_key?("HTTP_X_FORWARDED_FOR")
    respond_to do |format|
      format.json {
        if location = Location.from_host(ip)
          render :json => location.to_json
        else
          render :nothing => true, :status => 404
        end
      }
    end
  end
  
  def get_code_for
    if params[:host].blank?
      render :nothing => true, :status => 400
    else
      host = URI.parse(params[:host].gsub('://', ':/').gsub(':/', '://')).host
      respond_to do |format|
        format.json {
          if location = Location.from_host(host)
            render :json => location.to_json
          else
            render :nothing => true, :status => 404
          end
        }
      end
    end
  end
end
