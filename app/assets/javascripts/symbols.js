;(function($) {
	
    $.extend($.fn, {
        symbols: function(){
            // your plugin logic
            
            var textarea = $(this);

            textarea.focusout(function(){
       			 textarea.data("lastSelection", textarea.getSelection());
    		});

            //check that character menu is not already showoiig

            //create symbols div
            var characters = [{"'º'":"º"},{"'²'":"²"},{"'³'":"³"},{"'±'":"±"},{"'≤'":"≤"},{"'≥'":"≥"}];
            $.each(characters, function(i, obj){
            	$.each(obj, function(key, value) {
            	//create list item
            	$('.character_menu_content').children('ul').append('<li id="symbol_'+i+'">'+value+'</li>');

       	
            	//attach clich event to each element
            	$('.character_menu_content').children('ul').children('li#symbol_'+i).click(function(event){
 					var $target = $(event.target); // the element that fired the original click event

        			var selection = textarea.data("lastSelection");
    				textarea.focus();
    				textarea.setSelection(selection.start, selection.end);
    				textarea.replaceSelectedText(value);
           			t = setTimeout(function() {
                    	$('.character_menu_content').children('ul').children('li').remove();
                	}, 200);            		           	
            	});
            });

         });    
        }
    });


})(jQuery);