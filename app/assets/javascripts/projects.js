function form_input() {
	var label_width = $('.form_input_label').width();
	var table_width = $('.column_1, .column_2, .column_3').find('table').width();
	var min_table_wdith = 270;

	if((min_table_wdith + label_width) > table_width) {
		$('.form_input').children('select').width(table_width-10);
	}
	else {
		$('.form_input').children('select').width((table_width-label_width-10));
	}
}
	
function section_select_location(){
	var label_width = $('div.section_select_desktop').find('.select_1').outerWidth();
	var select_width = $('div.section_select_desktop').find('select').width();
	var location = (label_width + select_width + 20);

	//if ($(window).width() > 800){ //refer to meduium menu size set in core.css
		$('.select_2').css({'left': location +"px"});
	//}else{
	//	$('.select_2').css({'left': "0px"});	
	//}
}




$(document).ready(function(){

//query for tabulated views	
$('ul.tabs, ul.tabs_2').each(function(){
    // For each set of tabs, we want to keep track of
    // which tab is active and it's associated content
    var $active, $content, $links = $(this).find('a');

    // If the location.hash matches one of the links, use that as the active tab.
    // If no match is found, use the first link as the initial active tab.
    $active = $($links.filter('[href="'+location.hash+'"]')[0] || $links[0]);
    $active.addClass('active');
    $content = $($active.attr('href'));

    // Hide the remaining content
    $links.not($active).each(function () {
        $($(this).attr('href')).hide();
    });

    // Bind the click event handler
    $(this).on('click', 'a', function(e){
        // Make the old tab inactive.
        $active.removeClass('active');
        $content.hide();

        // Update the variables with the new link and content
        $active = $(this);
        $content = $($(this).attr('href'));

        // Make the tab active.
        $active.addClass('active');
        $content.show();

        // Prevent the anchor's default click action
        e.preventDefault();
    });
});



//table input width for new user
	form_input();	
	section_select_location();
	$(window).resize(function(){
		form_input();
		section_select_location();
	});	


	$('.project_option_select').children('select').selectBox({autoWidth: false});
	$('select#section, select#subsection').selectBox({autoWidth: false});
	$('select#revision').selectBox().selectBox({autoWidth: false});

	

//show/hide user settings menu
	$('nav.app_user_name').click(function (){
		$('nav.app_user_menu').toggle();
	});
  
	$('nav.app_user_menu').mouseleave(function (){
		$(this).hide();
	});

//show or hide website mobile menu settings menu
	$('nav.app_mob_menu').click(function (){
		$('nav.mob_spec_menu').toggle();
	});
  
	$('nav.mob_spec_menu').mouseleave(function (){
		$(this).hide();
	});





//sortable specline
	$('.1, .2, .3, .4, .5, .6, .prelim_show').sortable({
		axis: 'y',
		cancel: '.clause_title, span',
		cursor: 'pointer',
		handle: 'td.prefixed_line_menu img',
		stop: function(event, ui){
			var sortorder=$(this).sortable('toArray');
			var moved = $(ui.item).attr('id');	
   
			$.ajax({
				type: 'put',
				url: '/speclines/'+moved+'/move_specline',
				dataType: 'script',
				data: 'table_id_array='+sortorder +'',
				complete: function(){}
			});   
		}	 		
	});

//show/hide character menu
//	$('.editable_text4, .editable_text5').click(function(){
//  		$('.character_menu').css('visibility','visible');
//	});




//show/hide functions for spec and clause lines menus
	$('.specline_table').hover(function(){
		$(this).css('background-color', '#efefef');
		$(this).find('td.prefixed_line_menu').css('visibility', 'visible');
		$(this).find('td.suffixed_line_menu').css('visibility', 'visible');
		$(this).find('td.suffixed_line_menu_mob').css('visibility', 'visible');
	},
	function (){
  		$(this).css('background-color', '#fff');
		$(this).find('td.prefixed_line_menu').css('visibility', 'hidden');
		$(this).find('td.suffixed_line_menu').css('visibility', 'hidden');
		$(this).find('td.suffixed_line_menu_mob').css('visibility', 'hidden')
  	});
  	
//show/hide specline mob menu
	$('.suffixed_line_menu_mob').click(function (){
		$(this).closest('table').find('.specline_mob_menu_popup').toggle();
	});
 
	$('tr.specline_mob_menu_popup').mouseleave(function (){
		$(this).hide();
	});
	


//show/hide functions for rev lines
	$('.rev_table').hover(function (){
		$(this).css('background-color', '#efefef');
		$(this).find('td.rev_line_menu').css('visibility', 'visible');
		$(this).find('td.rev_line_menu_mob').css('visibility', 'visible');
  	},
  	function (){
		$(this).css('background-color', '#fff');
		$(this).find('td.rev_line_menu').css('visibility', 'hidden');
		$(this).find('td.rev_line_menu_mob').css('visibility', 'hidden');
  	});

//show/hide rev mob menu
	$('.rev_line_menu_mob').click(function (){
		$(this).closest('table').find('.rev_mob_menu_popup').toggle();
	});
 
	$('tr.rev_mob_menu_popup').mouseleave(function (){
		$(this).hide();
	});


$('a.get, a.delete, a[title]').tipsy();


//jeditbale functions
$.editable.addInputType('autogrow', {
                element : function(settings, original) {
                    var textarea = $('<textarea />');
                    if (settings.rows) {
                        textarea.attr('rows', settings.rows);
                    } else if (settings.height != "none") {
                        textarea.height(settings.height);
                    }

                   	textarea.width(settings.width);	                       	                       	

                    textarea.css("font", "normal 12px arial").css("padding-top", "0px");
                    $(this).append(textarea);
                    return(textarea);
                },
    			plugin : function(settings, original) {
        			$('textarea', this).symbols();
        			$('textarea', this).autogrow();
    			},
});



$('.editable_text3').mouseover(function(){
var spec_id = $(this).attr('id');
$(this).editable('/speclines/'+spec_id+'/update_specline_3', {id: spec_id, width: ($(this).width() +5)+'px', type: 'text', onblur: 'submit', method: 'PUT', indicator: 'Saving..', submitdata: {_method: 'put', 'id': '<%= @line.id%>', authenticity_token: AUTH_TOKEN}});    
}); 
$('.editable_text4').mouseover(function(){
var spec_id = $(this).attr('id');
var text_width = $(this).width();
$(this).editable('/speclines/'+spec_id+'/update_specline_4', {id: spec_id, width: $(this).width()+'px', type: 'autogrow', onblur: 'submit', method: 'PUT', indicator: 'Saving..', autogrow : {lineHeight : 16, maxHeight  : 512}, submitdata: {_method: 'put', 'id': '<%= @line.id%>', authenticity_token: AUTH_TOKEN}});    
}); 
$('.editable_text5').mouseover(function(){
var spec_id = $(this).attr('id');
$(this).editable('/speclines/'+spec_id+'/update_specline_5', {id: spec_id, width: $(this).width()+'px', type: 'autogrow', onblur: 'submit', method: 'PUT', indicator: 'Saving..', autogrow : {lineHeight : 16, maxHeight  : 512}, submitdata: {_method: 'put', 'id': '<%= @line.id%>', authenticity_token: AUTH_TOKEN}});    
});    
$('.editable_text6').mouseover(function(){
var spec_id = $(this).attr('id');
$(this).editable('/speclines/'+spec_id+'/update_specline_6', {id: spec_id, width: $(this).width()+'px', type: 'text', onblur: 'submit', method: 'PUT', indicator: 'Saving..', submitdata: {_method: 'put', 'id': '<%= @line.id%>', authenticity_token: AUTH_TOKEN}});    
});    


//specline linetype edit
$(document).on('click','.submittable2', function() {
 $(this).parents('form:first').submit();
   return false;
});


$('#clone_template_id').change(function(){
	var text = $('select#clone_clause_id option:selected').text();
	$('select#clone_clause_id option:selected').text('updating...');
})




//end
});
