function tab_format(){
	if ($('ul').hasClass('tabs_2')) {
       var listWidth = 40;
		$('.tabs_2 li').each(function(){
    		listWidth += ($(this).outerWidth()+4);
		});
		if($(window).width() >= listWidth) {
			$('ul.tabs_2').removeClass('tabs_2').addClass('tabs');			
			var tab_content_top = 36 + $('.tabs').position().top - 4;
			$('.tab_content').css('top', tab_content_top+"px").css('border-top', "none");
		}
		else{
			var tab_content_top = $('.tabs_2').height() + $('.tabs_2').position().top +10;
			$('.tab_content').css('top', tab_content_top+"px");
		}				
	}
	if ($('ul').hasClass('tabs')) {
		var listWidth = 40;
		$('.tabs li').each(function(){
    		listWidth += ($(this).outerWidth()+4);
		});
		if($(window).width() <= listWidth) {
			$('ul.tabs').removeClass('tabs').addClass('tabs_2');			 
			var tab_content_top = $('.tabs_2').height() + $('.tabs_2').position().top + 10;
			$('.tab_content').css('top', tab_content_top+"px").css('border-top', "2px solid #dddddd");	
		}
		else{
			var tab_content_top = 36 + $('.tabs').position().top - 4;
			$('.tab_content').css('top', tab_content_top+"px").css('border-top', "none");
		}		
	}
}


function form_input() {
	var label_width = $('.form_input_label').width();
	var table_width = $('.column_1, .column_2, .column_3').find('table').width();
	var min_table_wdith = 270;

	if((min_table_wdith + label_width) > table_width) {
		$('select#project_parent_id').width(table_width);
	}
	else {
		$('select#project_parent_id').width((table_width-label_width));
	}
}
	

function section_select_location(){
	if ($(window).width() > 800){ //refer to meduium menu size set in core.css
	var label_width = $('.select_1').outerWidth();
	var select_width = $('.document_selectBox_1').outerWidth();
	var location = (label_width + select_width +10);
	
		$('.select_2').css({'left': location +"px"});
	}else{
		$('.select_2').css({'left': "0px"});	
	}
}

//controls width of section and subsection select when select menu is stacked
function section_select_input_1_width(){
	if ($(window).width()<800){ //refer to meduium menu size set in core.css
		var select_width = ($(window).width() - 240);		
		$('.selectBox-dropdown').css({'max-width': select_width +"px"});
	}
}

//controls width of section and subsection select when select menus are inline
function section_select_input_1_2_width(){
	if ($(window).width()>800){ //refer to meduium menu size set in core.css
	
	var window_width = $(window).width();
	var section_label_width = $('.select_1').outerWidth();
	var subsection_label_width = $('.select_2').outerWidth();
	var subsection_button_width = $('.subsection_button').outerWidth();
	var select_width = ((window_width - section_label_width - subsection_label_width - subsection_button_width - 60)/2);	
	
	$('.selectBox-dropdown').css({'max-width': select_width +"px"});
	
	var location = (section_label_width + select_width +40);
	$('.select_2').css({'left': location +"px"});
	}
}

function tab_2_label_width(){
//limit label size in document end tabs
	if ($(window).width()<400){
		$('.document_tabs ul').find('a').each(function(){
			var text=$(this).text()
			if (text.length>14)
				$(this).val(text).text(text.substr(0,11)+'..')
		});
	}	
}	

$(document).ready(function(){


		$('select#section option').each(function(){
			var text=$(this).text()
			if (text.length>14)
				$(this).val(text).text(text.substr(0,13)+'…')
		})



//table input width for new user
	tab_format();
	form_input();
	tab_2_label_width();
	section_select_location();
	section_select_input_1_width()
	section_select_input_1_2_width()
	$(window).resize(function(){
		tab_format();
		form_input();
		tab_2_label_width();
		section_select_location();
		section_select_input_1_width()
		section_select_input_1_2_width()
	});	

//show/hide website mobile menu settings menu
	$('nav.app_mob_menu').click(function (){
		$('nav.mob_spec_menu').toggle();
	});
  
	$('nav.mob_spec_menu').mouseleave(function (){
		$(this).hide();
	});


//query for tabulated views	
$('ul.tabs').each(function(){
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

//special character menue
var characters = ['º', '¹','²', '³', '¼', '¾','±', '≠', '≤', '≥']
$.each(characters, function(val, text){
  $('.character_menu_content').children('ul').append($('<li class="character"></li>').val(val).html(text));
});


//sortable specline
$('.1, .2, .3, .4, .5, .6, #prelim_show').sortable({
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
   	complete: function(){
    }
   	});   
   }	 		
}) ;



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
  }  	
);

//show/hide functions for rev lines
$('tr.rev_row, tr.rev_row_strike, tr.clause_title_2').hover(function (){
  $(this).children('td.rev_line_menu').toggle();
  $(this).children('td.padding').toggle();
  $(this).css('background-color', '#efefef');
  },
  function (){
  $(this).children('td.rev_line_menu').toggle();
  $(this).children('td.padding').toggle();
  $(this).css('background-color', '#ffffff');
  }
);


//show/hide character menu
$('.editable_text4, .editable_text5').click(function(){
  $('.character_menu').css('visibility','visible');
});

//show/hide specline mob menu
	$('.suffixed_line_menu_mob').click(function (){
		$(this).closest('table').find('.specline_mob_menu_popup').toggle();
	});
 
	$('tr.specline_mob_menu_popup').mouseleave(function (){
		$(this).hide();
	});


$('a.get, a.delete, a[title]').tipsy();

//end
});
