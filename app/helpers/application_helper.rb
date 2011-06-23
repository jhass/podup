module ApplicationHelper
  def stars(n)
    r = ""
    n.times do
      r += image_tag "icons/star.png"
    end
    r.html_safe
  end
  
  def acceptance_state(state)
    if state
      r = image_tag "icons/accepted.png"
    else
      r = image_tag "icons/not_accepted.png"
    end
    r.html_safe
  end
end
