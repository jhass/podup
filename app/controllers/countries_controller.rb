require 'uri'

class CountriesController < ApplicationController
  
  respond_to :json, :only => [:get_code_for, :get_code_for_current_ip]
  
  def index
    @locations = Pod.accepted.active.collect { |x| x.location }
    @locations.uniq!
    @locations.sort! { |x, y| x.name.downcase <=> y.name.downcase }
  end
  
  def show
    begin
      @location = Location.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Couldn't find country"
      redirect_to countries_path
    else
      @pods = Pod.accepted.active.where(:location_id => @location.id).order('score DESC')
      if @pods.blank?
        flash[:error] = "Couldn't find any active pods for #{@location.name}"
        redirect_to countries_path
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
      host = params[:host]
      host = "http://#{host}" unless host.starts_with? "http"
      host = host.gsub(':/', '://').gsub(":///", "://")
      host = URI.parse(host).host
      respond_to do |format|
        format.any {
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
