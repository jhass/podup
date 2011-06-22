module ApplicationHelper
  def stars(n)
    r = ""
    n.times do
      r += image_tag "icons/star.png"
    end
    r.html_safe
  end
end
