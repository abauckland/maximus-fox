class FaqsController < ActionController::Base

layout "websites"

def index
   @faqs = Faq.all
end

    
end
