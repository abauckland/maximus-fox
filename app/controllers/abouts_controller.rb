class AboutsController < ActionController::Base

layout "websites"

  def index
    @contents = About.all
  end
    
end