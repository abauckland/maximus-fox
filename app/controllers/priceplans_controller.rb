class PriceplansController < ActionController::Base

layout "websites"

  def index
    @price_plans = Priceplan.all
  end
    
end