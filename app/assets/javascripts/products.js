
jQuery.ajaxSetup({
  beforeSend: function(xhr) {
    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
  }
});
//checks if is a function - required for some browsers (IE)
function _ajax_request(url, data, callback, type, method){
  if(jQuery.isFunction(data)){
    callback = data;
    data = {};
  }
  return jQuery.ajax({
  type: method,
  url: url,
  data: data,
  success: callback,
  dataType: type
  });  
}


//extends above
jQuery.extend({
  put: function(url, data, callback, type){
    return _ajax_request(url, data, callback, type, 'PUT');
  },
  delete_: function(url, data, callback, type){
    return _ajax_request(url, data, callback, type, 'DELETE');
  }
});


//Post ajax function
jQuery.fn.postWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.post($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};

//put ajax function
jQuery.fn.putWithAjax = function(){
  this.unbind('click',false);
  this.click(function(){
    $.put($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
    })
  return this;
};



//delete ajax function
jQuery.fn.deleteWithAjax = function(){
  this.removeAttr('onclick');
  this.unbind('click',false);
  this.click(function(){
    $.delete_($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
    })
  return this;
};

//get ajax function
jQuery.fn.getWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.get($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};


//this will ajaxify the link_to items
function ajaxLinks(){
$('a.delete').deleteWithAjax();
$('a.put').putWithAjax();
$('a.get').getWithAjax();
$('a.post').postWithAjax();
}



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


$('#products').dataTable()


//loads ajax functionality to links with specified class
ajaxLinks();



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


//show/hide functions for spec and clause lines menus

 $('tr.product_file_import_row').on({
    mouseenter:function(){ 
		$(this).find('td.product_file_import_delete').css('visibility', 'visible');
    },
    mouseleave:function(){ 
		$(this).find('td.product_file_import_delete').css('visibility', 'hidden');
    }
  });


  	
//show/hide specline mob menu
	$('.suffixed_line_menu_mob').click(function (){
		$(this).closest('table').find('.specline_mob_menu_popup').toggle();
	});
 
	$('tr.specline_mob_menu_popup').mouseleave(function (){
		$(this).hide();
	});
	

//export product data by clause list
$('input#data_company_clauses').click(function (){
  $('select#clause_ids').removeAttr('disabled');
});

$('input#data_company_template, input#data_company_data').click(function (){
  $('select#clause_ids').attr('disabled', 'disabled');
});



$('td.suffixed_line_menu').children('a').tipsy();
$('td.prefixed_line_menu').children('img').tipsy();

//end
});
