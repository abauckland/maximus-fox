module TermsHelper

def term_items(cat)
    @terms = Term.where(:cat=> cat)
end

end
