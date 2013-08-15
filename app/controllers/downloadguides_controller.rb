
    class DownloadguidesController < ApplicationController

    
      def index
        #respond_with Guidepdf.all
        @guides = Guidepdf.all
          respond_to do |format|
    format.html
    format.json { render json: @guides }
  end
        #respond with hash of download address, code and title of guide, and download site id
        #@downloadguides = {}
        #guides.each_with_index do |g, i|        
          #@downloadguides[i][0] = g.title
          #download_link = 'http://www.specright.co.uk/downloadguides/' << g.id << '?....?????'
          #@downloadguides[i][1] = download_link                
        #end

        #respond_with @downloadguides
      end


    end
