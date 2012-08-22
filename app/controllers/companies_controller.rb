class CompaniesController < ApplicationController
#before_filter :authenticate_user!

before_filter :require_user, :except => [:new, :create]

layout "application", :except => [:edit]


  # GET /companies/1
  # GET /companies/1.xml
  def show
    @companies = Company.all

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @company }
    end
  end


  # GET /companies/1/edit
  def edit
      
    @current_user = User.where('id = ? ', current_user.id).first    
    if @current_user.role == 'user'
      redirect_to log_out_path
    else  
    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    @company = Company.find(current_user.company_id)
    
    end
    respond_to do |format|
      format.html   { render :layout => 'projects'}
      format.xml  { render :xml => @company, :layout => 'project'}
    end
  end

  
  # GET /companies/new
  # GET /companies/new.xml
  def new
    @company = Company.new
     user = @company.users.build
  end


  # POST /companies
  # POST /companies.xml
  def create
    @company = Company.new(params[:company])
    check_company = Company.where('company_name =?', @company.company_name)
    #if !check_company.blank?
    #  redirect_to sign_up_path
    #end

    respond_to do |format|
      if @company.save
      
        @new_account = Account.new do |n|
           n.company_id = @company.id
           n.no_licence = 1
        end
        @new_account.save
        
        @current_project = Project.new do |n|
          n.code = 'D1'
          n.title = 'Demo Project'
          n.parent_id = 2
          n.project_status = 'Draft'
          n.rev_method = 'Project'
          n.company_id = @company.id          
        end
        @current_project.save
        
        
     
        user = User.where('company_id =?', @company.id).first    
        session[:user_id] = user.id  
        #redirect_to projects_path
        
        licence = Licence.new
        licence.user_id = user.id
        licence.active_licence = 1
        licence.save
   
      set_current_revision = Revision.create(:project_id => @current_project.id, :user_id => user.id, :date => Date.today)
      
        #flash[:notice] = 'Company was successfully created.'
        format.html { redirect_to(@current_project) }
        #format.xml  { render :xml => @company, :status => :created, :location => @company }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
     #@user = User.first
     # UserMailer.registration_confirmation(@user).deliver
      end
    end
  end
  
    # PUT /specs/1
  # PUT /specs/1.xml
  def update_www
    @company = Company.find(params[:id])
    @company.www = params[:value]
    @company.save
    render :text=> params[:value]
  end

  # PUT /companies/1
  # PUT /companies/1.xml
  def update
    @company = Company.find(params[:id])

    respond_to do |format|
    
    @company.update_attributes(params[:company])
    

      @current_project = Project.where(:id => params[:current_project]).first
        format.html { redirect_to(edit_company_path(@company)) }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }

    end
  end

end
