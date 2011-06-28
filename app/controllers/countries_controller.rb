class CountriesController < ApplicationController

  def index
    @locations = Pod.accepted.active.collect { |x| x.location }
    @locations.uniq!
    @locations.sort! { |x,y| x.name <=> y.name }
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
end
