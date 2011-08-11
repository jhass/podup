module ApplicationHelper
  def stars(n, total=5)
    r = ""
    n.times do
      r += image_tag "icons/star.png"
    end
    (total-n).times do
      r += image_tag "icons/star_inactive.png"
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
  
  def uptime(time_or_nil)
    r = "Up since "
    if time_or_nil
      r += time_ago_in_words(time_or_nil)
    else
      r += "never"
    end
    r.html_safe
  end
end
