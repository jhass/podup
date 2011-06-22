module PodsHelper
  def location(pod)
    r = ""
    r += image_tag pod.location.flag_path
    r += " "
    r += pod.location.name
    r.html_safe
  end
end
