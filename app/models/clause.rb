class Clause < ActiveRecord::Base
#associations

has_many :projects, :through => :speclines
has_many :changes
has_many :speclines, :uniq => true

belongs_to :clauseref, :include => [:clausetype]
belongs_to :clausetitle
belongs_to :guidenote

has_many :associations
has_many :associates, :through => :associations

accepts_nested_attributes_for :clauseref
accepts_nested_attributes_for :clausetitle

attr_accessor :title_text

before_validation :custom_validation_2
before_save :assign_title



def clause_section_full_title
#this needs to be sorted, unclear what is going on
    clauseref.subsection.section.ref.to_s + sprintf("%02d", clauseref.subsection.ref).to_s + '.' + clauseref.clausetype_id.to_s + sprintf("%02d", clauseref.clause).to_s + clauseref.subclause.to_s + ' ' + clausetitle.text.to_s
end

def clause_full_title
#this needs to be sorted, unclear what is going on
    clauseref.clausetype.text.to_s + ' ' + clauseref.clausetype_id.to_s + sprintf("%02d", clauseref.clause).to_s + clauseref.subclause.to_s + ': ' + clausetitle.text.to_s
end

def clause_code
#this needs to be sorted, unclear what is going on
  clauseref.subsection.section.ref.to_s + sprintf("%02d", clauseref.subsection.ref).to_s + '.' + clauseref.clausetype_id.to_s + sprintf("%02d", clauseref.clause).to_s + clauseref.subclause.to_s
end


def custom_validation_2
    if @title_text.blank?
      errors.add(:title_text, "Clause title cannot be blank")
    end 
end

private
  def assign_title
    if @title_text
      text_exist = Clausetitle.where('BINARY text =?', @title_text).first
      if text_exist.blank?
         self.clausetitle = Clausetitle.create(:text => @title_text)
      else
         self.clausetitle = text_exist
      end    
    end
  end

end
