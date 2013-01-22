module ProductsHelper

  
  def product_performance_text(product_id, txt3_id)
      performance_txt6_text = Txt6.joins(:performances => [:characteristics]).where('performances.txt3_id' => txt3_id, 'characteristics.product_id' => product_id).first      
      if performance_txt6_text
        "<td>#{performance_txt6_text.text}</td>".html_safe
      else
        "<td></td>".html_safe     
      end
  end
  
  
end