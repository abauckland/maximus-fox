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
        authenticate_or_request_with_http_token do |token, options|
          apiKey = User.where(api_key: token).first
          head :unauthorized unless api_key
        end
      end

    end
  end   
end