class FeaturesController < ActionController::Base

layout "websites"

def index
   @features = Feature.where(:id => 1..6)
    
  respond_to do |format|
    format.html # index.html.erb
    format.xml  { render :xml => @features}
  end  
end

def show
   @feature = Feature.where('id = ?', params[:id]).first
   
   feature_id = []
   feature_id[0] = @feature.id
   feature_ids_array = [1,2,3,4,5,6]
   feature_id_array = feature_ids_array - feature_id
   
   @features = Feature.where(:id => 1..6)
   @features_2 = Feature.where(:id => feature_id_array)

end 

    
end
