class GuidepdfsController < ApplicationController

#before_filter :require_user, :except => [:index]
layout "application", :except => [:show]

 def index
  @guidepdfs = Guidepdf.includes(:subsection => :section).all#.order('sections.id, subsections.id')
 end


 def show
   guidepdfs = Guidepdf.where(:subsection_id => params[:subsection_ids])#.collect{|i| i.id}
   
   #guidepdf = Guidepdf.where(:subsection_id => params[:subsection_id]).first
   
   if guidepdfs
    guidepdfs.each do |guidepdf| 
      #have to change config files to get app to send file
      send_file("#{Rails.root}/public#{guidepdf.pdf.url.sub!(/\?.+\Z/, '') }", :type => 'application/pdf', :filename => guidepdf.photo_file_name)   
   
      #record download
      #capture IP address
      ip = request.remote_ip
      @guide_downloads = Guidedownload.new(:guidepdf_id => guidepdf.id, :ipaddress => ip)
      @guide_downloads.save
    end
   end
 end




end
