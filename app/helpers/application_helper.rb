module ApplicationHelper

  #Return a title on a per-page basis.
  def title
    base_title = "Our Bulletins"
    if @title.nil?
      base_title
    else
      "#{@title} | #{base_title}"
    end
  end

  def app_name
    app_name = "Our Bulletins"
  end
end
