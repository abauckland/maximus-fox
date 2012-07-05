class AboutsController < ActionController::Base

layout "application"

def index
   @abouts = About.all
end

    
end
