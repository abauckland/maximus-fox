class UsersController < ApplicationController

before_filter :require_user

layout "users"

#! new action not used?
# layout "projects", :except => [:new]

  #user details edit
  def show
    #check project ownership private method    
    @user = User.where(:id => params[:id]).first
  end
    
  #create new user
  #form only shown where at least one free licence
  #full page re-render upon cmopletion of action  
  def create 

   # @current_project = Project.where('id = ? AND company_id =?', params[:user][:id], current_user.company_id).first
    
  #  if @current_project.blank?
   #   redirect_to log_out_path
  #  end
    
    @company = Company.where('id =?', current_user.company_id).first    
    @array_user_ids = User.where(:company_id => current_user.company_id).collect{|i| i.id}.sort
    @licences = Licence.where(:user_id => @array_user_ids)
    @active_licences = Licence.where(:user_id => @array_user_ids, :active_licence => 1)
    @account = Account.where(:company_id => current_user.company_id).first

    @user = User.new(params[:user])  
                 
    @permisable_licences = Account.where('company_id =?', current_user.company_id ).first
    total_licences_used = User.where('company_id =?', current_user.company_id ).count
               
      if @user.save
      
        licence = Licence.new
        licence.user_id = @user.id
        licence.save
        
        redirect_to(:controller => "users", :action => "edit", :id => current_user.id)
      else
      #! not sure this is ever accessed
      respond_to do |format| 
        format.html { render :action => "edit", :id => current_user.id}
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end 
    end  
  end

  #company licence management
  def edit
    #check project ownership private method
          
    @company = Company.where('id =?', current_user.company_id).first
    @array_user_ids = User.where(:company_id => current_user.company_id).collect{|i| i.id}.sort
    @licences = Licence.where(:user_id => @array_user_ids)
    @active_licences = Licence.where(:user_id => @array_user_ids, :active_licence => 1)
    @account = Account.where(:company_id => current_user.company_id).first
    @available_licences = @account.no_licence - @active_licences.count
    @licence = params[:licence]
    
    #create new User object for form
    @user = User.new  
  end
  
  
  def update
     
    #@current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    
    #if @current_project.blank?
    #  redirect_to log_out_path
    #end
    
    user = User.where('id = ?', current_user.id).first
    if User.authenticate(current_user.email, params[:user][:password]) == user

      user.first_name = params[:user][:first_name]
      user.surname = params[:user][:surname]
      user.email = params[:user][:email] 
      if params[:new_password] == params[:new_password_confirmation]  
        user.password = params[:new_password]    
      end
     user.save
    end
    #  respond_to do |format| 
    #    format.html { render :action => "show", :id => current_user.id}
    #  end
    #logout, as session no longer valid for new password
    redirect_to log_out_path
  end


  #ajax event  
  def update_licence_status
    @licence = Licence.where('user_id =?', params[:id]).first

    if @licence.locked_at != 0
      @licence.locked_at = 0
    end

    @company = Company.where('id =?', current_user.company_id).first       
    @licences = Licence.joins(:user).where('users.company_id' => current_user.company_id)    
    @active_licences = Licence.joins(:user).where('users.company_id' => current_user.company_id, :active_licence => 1)
    @account = Account.where(:company_id => current_user.company_id).first
    
    @available_licences = @account.no_licence - @active_licences.count
     
    if @licence.active_licence == 1
      @licence.active_licence = 0                     
      @available_licences = @account.no_licence - @active_licences.count + 1 
    else      
      if @available_licences >= 0        
        @licence.active_licence = 1         
        @available_licences = @account.no_licence - @active_licences.count - 1          
      end
    end
    @licence.save

    #create new User object for form
    @user = User.new 
            
    redirect_to(:controller => "users", :action => "edit", :id => current_user.id)

  end

  
  #ajax event
  def unlock_user
    @licence = Licence.where('user_id =?', params[:id]).first    
    @licence.failed_attempts = 0
    @licence.locked_at = 0
    @licence.save

    respond_to do |format|
        format.js   { render :unlock_user, :layout => false }
    end  
  
  end  
   
end