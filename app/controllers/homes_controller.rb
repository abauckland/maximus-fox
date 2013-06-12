class HomesController < ActionController::Base

  def index
    @home = Home.first
    
    respond_to do |format|  
      format.html   { render :layout => 'websites'} 
    end
  end
  
  def combined_home
    @home = Home.where(:id => 1).first
    
    respond_to do |format|  
      format.html   { render :layout => 'combines'}
    end     
  end

  def supplier_home
    @home = Home.where(:id => 1).first
    
    respond_to do |format|  
      format.html   { render :layout => 'suppliers'} 
    end    
  end
       
end