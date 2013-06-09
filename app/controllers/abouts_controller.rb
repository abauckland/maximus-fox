class AboutsController < ActionController::Base

layout "websites"

  def index
    @abouts = About.all
  end
    
end