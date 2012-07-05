class HomesController < ActionController::Base

before_filter :prepare_for_mobile
before_filter :mobile_redirect, :except => :new

layout "application"

  # GET /homes
  # GET /homes.xml
  def index
    @home = Home.first
    @reference = Reference.first
  end
  
  def new
    @home = Home.new
    #@reference = Reference.first
  end

  protected  
  def mobile_device?  
    if session[:mobile_param]  
      session[:mobile_param] == "1"  
    else  
      request.user_agent =~ /Mobile|webOS/  
    end  
  end  
  helper_method :mobile_device?
  
  def prepare_for_mobile  
  session[:mobile_param] = params[:mobile] if params[:mobile]  
  request.format = :mobile if mobile_device?  
end

  def mobile_redirect
    if mobile_device?
      redirect_to(mob_home_path)
    end
  end
    
end