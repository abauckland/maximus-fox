module Api
  module V1
    class DownloadguidesController < ApplicationController
      before_filter :restrict_access
      respond_to :json
      
      def index
        respond_with Guidepdf.all
        #guides = Guidepdf.all
        
        #respond with hash of download address, code and title of guide, and download site id
        #@downloadguides = {}
        #guides.each_with_index do |g, i|        
          #@downloadguides[i][0] = g.title
          #download_link = 'http://www.specright.co.uk/downloadguides/' << g.id << '?....?????'
          #@downloadguides[i][1] = download_link                
        #end

        #respond_with @downloadguides
      end
      
      private
      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          User.exists?(access_token: token)
        end
      end

    end
  end   
end