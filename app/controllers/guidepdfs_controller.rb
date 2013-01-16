class GuidepdfsController < ApplicationController

before_filter :prepare_for_mobile
#before_filter :require_user, :except => [:index]
layout "application", :except => [:show, :new]

 def index
  @guidepdfs = Guidepdf.includes(:subsections => :section).all#.order('sections.id, subsections.id') 
       respond_to do |format|  
        format.html 
        format.mobile {render :layout => "mobile"}
      end   
 end


 def download
   subsection = Subsection.where(:id => params[:subsection_ids]).first
   
   guidepdfs = Guidepdf.where(:id => subsection.guidepdf_id)
   
   if guidepdfs
    guidepdfs.each do |guidepdf|

      send_file("#{Rails.root}/public#{guidepdf.photo.url.sub!(/\?.+\Z/, '') }", :type => 'application/pdf', :filename => guidepdf.photo_file_name)   
   
      #record download
      if defined?(current_user)
        current_user_id = current_user.id
      end
      
      #capture IP address
      ip = request.remote_ip
      @guide_downloads = Guidedownload.new(:guidepdf_id => guidepdf.id, :user_id => current_user_id, :ipaddress => ip)
      @guide_downloads.save
    end
   end
 end

end
 