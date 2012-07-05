class PricesController < ActionController::Base

layout "application"

  def index
    @plans = Price.all
    @feature = Feature.where('id=?', 7).first
    @properties = Property.where('feature_id =?', @feature.id)
  end
    
end