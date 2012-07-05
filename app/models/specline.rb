class Specline < ActiveRecord::Base
#associations
belongs_to :project
belongs_to :clause

has_many :changes

belongs_to :txt1
belongs_to :txt2
belongs_to :txt3
belongs_to :txt4
belongs_to :txt5
belongs_to :txt6

belongs_to :linetype



#virtual attribute
def txt3_text
  txt3.text if txt3
end

def txt4_text
  txt4.text if txt4
end

def txt5_text
  txt5.text if txt5
end

def txt6_text
  txt6.text if txt6
end

def txt3_text=(text)
  self.txt3 = Txt3.find_or_create_by_text(text) unless text.blank?
end

def txt4_text=(text)
  self.txt4 = Txt4.find_or_create_by_text(text) unless text.blank?
end

def txt5_text=(text)
  self.txt5 = Txt5.find_or_create_by_text(text) unless text.blank?
end

def txt6_text=(text)
  self.txt6 = Txt6.find_or_create_by_text(text) unless text.blank?
end


end
