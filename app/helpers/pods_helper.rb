module PodsHelper
  def location_for(object)
    if object.is_a?(Pod)
      location = object.location
    else
      location = object
    end
    r = ""
    r += image_tag location.flag_path
    r += " "
    r += location.name
    link_to(r.html_safe, country_path(location))
  end
end
