class UsersController < ApplicationController

before_filter :require_user, :except => [:new, :create]
before_filter :check_project_ownership, :except => [:create, :update_user_details, :unlock_user, :update_licence_status]
layout "projects", :except => [:new]

#layout "application", :except => [:edit]

  def new  
    @user = User.new
  end
    
    
  def create 

    @current_project = Project.where('id = ? AND company_id =?', params[:user][:id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end
    
    @company = Company.where('id =?', current_user.company_id).first    
    @array_user_ids = User.where(:company_id => current_user.company_id).collect{|i| i.id}.sort
    @licences = Licence.where(:user_id => @array_user_ids)
    @active_licences = Licence.where(:user_id => @array_user_ids, :active_licence => 1)
    @account = Account.where(:company_id => current_user.company_id).first

    @user = User.new(params[:user])  
                 
    @permisable_licences = Account.where('company_id =?', current_user.company_id ).first
    total_licences_used = User.where('company_id =?', current_user.company_id ).count
      
   # if total_licences_used < @permisable_licences.no_licence    
        
       
      if @user.save
      
        licence = Licence.new
        licence.user_id = @user.id
        licence.save
        
        redirect_to(:controller => "users", :action => "edit", :id => @current_project.id)
      else
      respond_to do |format| 
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end 
    #end
    end  
  end

  
  def edit
  

    @user = User.new 
    #@user = User.includes(:company).where(:id => current_user.id).first
    
    @company = Company.where('id =?', current_user.company_id).first
    @array_user_ids = User.where(:company_id => current_user.company_id).collect{|i| i.id}.sort
    @licences = Licence.where(:user_id => @array_user_ids)
    @active_licences = Licence.where(:user_id => @array_user_ids, :active_licence => 1)
    @account = Account.where(:company_id => current_user.company_id).first
    @available_licences = @account.no_licence - @active_licences.count
    @licence = params[:licence]
  end
  
  
  def edit_user_details

    @user = User.where(:id => current_user.id).first
  end

  
  def update_user_details
     
    @user = User.where('id = ?', current_user.id).first
    if User.authenticate(current_user.email, params[:user][:password]) == @user

      @user.first_name = params[:user][:first_name]
      @user.surname = params[:user][:surname]
      @user.email = params[:user][:email] 
      if params[:new_password] == params[:new_password_confirmation]  
        @user.password = params[:new_password]    
      end
      @user.save
    end
    redirect_to edit_user_details_user_path(params[:id]) #@current_project.id
  end


  
  def update_licence_status
    @licence = Licence.where('user_id =?', params[:id]).first

    if @licence.locked_at != 0
      @licence.locked_at = 0
    end

  array_user_ids = User.where(:company_id => current_user.company_id).collect{|i| i.id}.sort
  @active_licences = Licence.where(:user_id => array_user_ids, :active_licence => 1)
  @account = Account.where(:company_id => current_user.company_id).first
  @available_licences = @account.no_licence - @active_licences.count
     
    if @licence.active_licence == 1
        @licence.active_licence = 0
                     
        respond_to do |format|
            @licence.save
            @new_available_licences = @available_licences + 1
            format.js   { render :update_licence_status, :layout => false }
        end 
    else      
        if @available_licences > 0        
          @licence.active_licence = 1
                    
          respond_to do |format|
            @licence.save
            @new_available_licences = @available_licences - 1 
            format.js   { render :update_licence_status, :layout => false }
          end
      end
    end
    @user = User.new  
end
  
  def unlock_user
    @licence = Licence.where('user_id =?', params[:id]).first    
    @licence.locked_at = 0
    @licence.save

    respond_to do |format|
        format.js   { render :unlock_user, :layout => false }
    end  
  
  end  

protected
def check_project_ownership
    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end
end    
end