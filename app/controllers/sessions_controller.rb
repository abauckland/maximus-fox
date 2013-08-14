class SessionsController < ApplicationController

layout "mobiles"

  def new
  
      respond_to do |format|  
        format.html 
        format.mobile {render :layout => "mobile"}
      end    
  end
     
  #used by mobile login - session/new
  def create

    if params[:email].blank? || params[:password].blank?
       redirect_to home_path, notice: 'show forgotten password link'      
    else
    
    email_check = User.where('email = ?', params[:email]).first      
    if email_check.blank? 
      redirect_to home_path, notice: 'show forgotten password link'       
    else
      
    user = User.authenticate(params[:email], params[:password]) 
    if user  
      session[:user_id] = user.id  

      user = User.where('email=?', params[:email]).first
      @licence = Licence.where('user_id = ?', user.id).first      
      if @licence.locked_at == 1
        #redirect to locked page        
        redirect_to(:controller => 'password_resets', :action => 'locked', :id => @licence.id)
      else
        if @licence.active_licence == 0
          #redirect to inactive licence page 
          redirect_to(:controller => 'password_resets', :action => 'deactivated', :id => @licence.id)         
        else    
        @licence.last_sign_in = Time.now
        @licence.number_times_logged_in = @licence.number_times_logged_in += 1
        @licence.ip = request.remote_ip
        @licence.failed_attempts = 0
        @licence.save
            
        redirect_to projects_path
        end
      end      
    else
    
      user = User.where('email=?', params[:email]).first
      @licence = Licence.where('user_id = ?', user.id).first 
      @licence.failed_attempts = @licence.failed_attempts += 1
      if @licence.failed_attempts == 3
        #if user.role != 'admin'
          @licence.locked_at = 1
        #end
      end      
      @licence.save 
      redirect_to new_session_path, notice: 'show forgotten password link' 
    end      
  end
  end
  end  
  
  #used by homepage (root) login
  def create_session  

    if params[:email].blank? || params[:password].blank?
       redirect_to home_path, notice: 'show forgotten password link'      
    else
    
    email_check = User.where('email = ?', params[:email]).first      
    if email_check.blank? 
      redirect_to home_path, notice: 'show forgotten password link'       
    else
      
    user = User.authenticate(params[:email], params[:password]) 
    if user  
      session[:user_id] = user.id  

      user = User.where('email=?', params[:email]).first
      @licence = Licence.where('user_id = ?', user.id).first      
      if @licence.locked_at == 1
        #redirect to locked page        
        redirect_to(:controller => 'password_resets', :action => 'locked', :id => @licence.id)
      else
        if @licence.active_licence == 0
          #redirect to inactive licence page 
          redirect_to(:controller => 'password_resets', :action => 'deactivated', :id => @licence.id)         
        else    
        @licence.last_sign_in = Time.now
        @licence.number_times_logged_in = @licence.number_times_logged_in += 1
        @licence.ip = request.remote_ip
        @licence.failed_attempts = 0
        @licence.save
            
        redirect_to projects_path
        end
      end      
    else
    
      user = User.where('email=?', params[:email]).first
      @licence = Licence.where('user_id = ?', user.id).first 
      @licence.failed_attempts = @licence.failed_attempts += 1
      if @licence.failed_attempts == 3
        #if user.role != 'admin'
          @licence.locked_at = 1
        #end
      end      
      @licence.save 
      redirect_to home_path, notice: 'show forgotten password link' 
    end  
  end

end
end

  
  def destroy  
    session[:user_id] = nil  
    redirect_to home_path 
  end
  
     
end
