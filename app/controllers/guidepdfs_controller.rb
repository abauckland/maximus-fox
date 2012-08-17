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
   guidepdf_ids = Subsection.where(:id => params[:subsection_ids])#.collect{|i| i.id}
   
   guidepdfs = Guidepdf.where(:id => guidepdf_ids)
   
   if guidepdfs
    guidepdfs.each do |guidepdf|

      send_file("#{Rails.root}/public#{guidepdf.photo.url.sub!(/\?.+\Z/, '') }", :type => 'application/pdf', :filename => guidepdf.photo_file_name)   
   
      #record download
      #capture IP address
      ip = request.remote_ip
      @guide_downloads = Guidedownload.new(:guidepdf_id => guidepdf.id, :ipaddress => ip)
      @guide_downloads.save
    end
   end
 end

end
 