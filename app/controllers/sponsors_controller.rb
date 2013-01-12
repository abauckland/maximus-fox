class SponsorsController < ActionController::Base


  def show
  
    sponsor = Sponsor.where(:id => params[:id]).first
    
    if defined?(current_user)
      current_user_id = current_user.id
    end
    
    #record visit
      #capture IP address
      ip = request.remote_ip
      sponsorvisit = Sponsorvisit.new(:sponsor_id => sponsor.id, :user_id => current_user_id, :ipaddress => ip)
      sponsorvisit.save
 
    #redirect to sponsor's website
    redirect_to 'http://' << sponsor.www
    
  end

    
end
