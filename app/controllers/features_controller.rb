class FeaturesController < ActionController::Base

layout "websites"

def index
   @contents = Feature.where(:id => 1..6)
    
  respond_to do |format|
    format.html # index.html.erb
    format.xml  { render :xml => @contents}
  end  
end

def show
    @feature = Feature.where('id = ?', params[:id]).first
    @feature_contents = Featurecontent.where(:feature_id => params[:id])
      
    @menu_contents = Feature.where(:id => 1..6).where('id <> ?', params[:id])

end 

    
end
