class TermsController < ActionController::Base

layout "websites"

  def index
    @cats = Term.select('DISTINCT cat').all.collect{|item| item.cat}
    @terms = Term.all
  end
    
end