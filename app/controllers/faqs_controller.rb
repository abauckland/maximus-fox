class FaqsController < ActionController::Base

layout "application"

def index
   @faqs = Faq.all
end

    
end
