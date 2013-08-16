;(function($) {
	
    $.extend($.fn, {
        symbols: function(){
            
			var textarea = $(this);
			                        
            textarea.focus(function(){
       			t = setTimeout(function() {
       			$('.character_menu').css('visibility', 'visible');
       			}, 200);
 			});
            
            
            $('.character_menu_content').children('ul').children('li#symbol_0').click(function(event){
        		textarea.selection('replace', {text: 'º'});        					            
				t = setTimeout(function() {
					$('.character_menu').css('visibility', 'hidden'); 
				}, 200);
			});
			
			$('.character_menu_content').children('ul').children('li#symbol_1').click(function(event){
        		textarea.selection('replace', {text: '²'});        					            
				t = setTimeout(function() {
					$('.character_menu').css('visibility', 'hidden'); 
				}, 200);
			});
			
			$('.character_menu_content').children('ul').children('li#symbol_2').click(function(event){
        		textarea.selection('replace', {text: '³'});        					            
				t = setTimeout(function() {
					$('.character_menu').css('visibility', 'hidden'); 
				}, 200);
			});

			$('.character_menu_content').children('ul').children('li#symbol_3').click(function(event){
        		textarea.selection('replace', {text: '±'});        					            
				t = setTimeout(function() {
					$('.character_menu').css('visibility', 'hidden'); 
				}, 200);
			});
									
			$('.character_menu_content').children('ul').children('li#symbol_4').click(function(event){
        		textarea.selection('replace', {text: '≤'});        					            
				t = setTimeout(function() {
					$('.character_menu').css('visibility', 'hidden'); 
				}, 200);
			});
			
			$('.character_menu_content').children('ul').children('li#symbol_5').click(function(event){
        		textarea.selection('replace', {text: '≥'});        					            
				t = setTimeout(function() {
					$('.character_menu').css('visibility', 'hidden'); 
				}, 200);
			});
			
			textarea.blur(function(){
          		t = setTimeout(function() {
            		$('.character_menu').css('visibility', 'hidden');
            	}, 100);
			});

          } 
    });
})(jQuery);