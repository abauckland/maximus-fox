class HomesController < ActionController::Base

layout "websites"

  def index
    @home = Home.first
    @reference = Reference.first
    @features = Feature.all
    
    respond_to do |format|  
      format.html 
    end
  end
  
  def new
    @home = Home.new
  end
    
end