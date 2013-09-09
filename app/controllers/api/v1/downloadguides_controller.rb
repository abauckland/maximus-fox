module Api
  module V1
    class DownloadguidesController < ApplicationController
      include ActionController::HttpAuthentication::Token
     before_filter :restrict_access
      respond_to :json
      
      def index
        #respond_with Guidepdf.all
        guides = Guidepdf.select('id, title').all
        
        #respond with hash of download address, code and title of guide, and download site id
        @downloadguides = guides
        #guides.each_with_index do |g, i|        
        #  download_link = 'http://www.specright.co.uk/downloadguides/' << g.id.to_s
         # @downloadguides[i]= [g.title, download_link]                        
        #end

        respond_with @downloadguides
      end
      
      private
      def restrict_access        
         if params[:access_token].nil?
           redirect_to log_out_path   
         else        
          api_key = User.where(:api_key => params[:access_token]).first
          if api_key
            redirect_to log_out_path     
          end
         end
      end
     end
  end   
end