class GuidepdfsController < ApplicationController

before_filter :prepare_for_mobile
#before_filter :require_user, :except => [:index]
layout "application", :except => [:download]

 def index
  @guidepdfs = Guidepdf.includes(:subsections => :section).all#.order('sections.id, subsections.id') 
       respond_to do |format|  
        format.html 
        format.mobile {render :layout => "mobile"}
      end   
 end


 def download
   #subsection = Subsection.where(:id => params[:id]).first
   
   #@project = Project.first
   @guidepdf = Guidepdf.where(:id => params[:id]).first
   
   if @guidepdf
  
      send_file("#{Rails.root}/public#{@guidepdf.pdf.url.sub!(/\?.+\Z/, '') }", :type => 'application/pdf', :filename => @guidepdf.pdf_file_name)   
      
      #record download
      if defined?(:current_user)
        if current_user
          current_user_id = current_user.id
          #capture IP address
          @guide_downloads = Guidedownload.create(:guidepdf_id => @guidepdf.id, :user_id => current_user_id, :ipaddress => request.remote_ip)
        else
          @guide_downloads = Guidedownload.create(:guidepdf_id => @guidepdf.id, :ipaddress => request.remote_ip)          
        end
      end
    end
  return
 end

end
 