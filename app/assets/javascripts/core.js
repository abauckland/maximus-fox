//function for setting column width depending on size of window	
function column_width(s_tab, mob, limit) {

var s_tab = s_tab;
var mob = mob;
var limit = limit;

var window_width = $(window).width();

  if(window_width <= limit) {
  	$('.column_1, .column_2, .column_3, .column_1_2').css({'width':"265px"});
  }  
  else if(window_width <= mob && window_width > limit) {  	
  	$('.column_2').css({'margin-right':"0px"}).css({'float':"left"}); 	
	var col_1_width = ($('.content').width())-24;   	  	  	
  	$('.column_1, .column_2, .column_3, .column_1_2').css({'width': col_1_width +"px"});
  }                                                                 
  else if(window_width <= s_tab && window_width > mob) {
  	$('.column_2').css({'margin-right':"0px"}).css({'float':"right"});    
	var col_1_width = (($('.content').width())-66)/2; 
  	var col_1_2_width = (($('.content').width())-66)/2;
  	var col_3_width = ($('.content').width())-24;  	  	
  	$('.column_1, .column_2').css({'width': col_1_width +"px"});  	
    $('.column_1_2, .column_3').css({'width': col_3_width +"px"});
  }                                                                  
  else {
  	var col_1_width = (($('.content').width())-102)/3;
  	var col_1_2_width = (($('.content').width())-48)*(2/3);  	
  	$('.column_1, .column_2, .column_3, .column_1_2').css({'float':"left"});
  	$('.column_1, .column_2, .column_1_2').css({'margin-right':"15px"});  	
  	$('.column_1, .column_2, .column_3').css({'width': col_1_width+"px"});
  	$('.column_1_2').css({'width': col_1_2_width+"px"});
  	
  }
}

//function to set height properties of column
function single_column_height(column_name) {
		var column_name = column_name;
		var totalHeight = 0;		
		if ($(column_name).children('.column_content').children('table.users').length){
			totalHeight = $(column_name).children('.column_content').children('table').height();
			if (totalHeight < 500){
			$(column_name).height(totalHeight);
			}else{	
			$(column_name).height(500);	
			}	
		}else{	
			$(column_name).children('.column_content').children('.column_sub_content').children().each(function(){
    			totalHeight = totalHeight + $(this).outerHeight(true);
			});
			$(column_name).children('.column_content').children('.column_sub_content').height(totalHeight);
			$(column_name).children('.column_content').children('.column_footer').css('top', (totalHeight+48) + 'px');
			$(column_name).height(totalHeight + 86);
		}
};


//function for setting column height depending on size of window	
function column_height(s_tab, mob, limit) {
var s_tab = s_tab;
var mob = mob;
var limit = limit;

	//set column height where all columns stacked
	if($(window).width() <= mob) {
		var array_columns = ['.column_1', '.column_2', '.column_1_2', '.column_3'];
		$.each(array_columns, function(i, column_name) {
			if ($(column_name).find('.column_title').length || $(column_name).find('table.users').length){
			single_column_height(column_name);
			}else{
			$(column_name).css('display', 'none');
			}
		});	
	}
	//set column height where two columns wide and one below
	else if($(window).width() <= s_tab && $(window).width() > mob) {
		//reset columns
		$('.column_2').css('display', 'block');
		//set column heights independently
		var array_columns = ['.column_1', '.column_2', '.column_1_2'];
		$.each(array_columns, function(i, column_name) { 
			single_column_height(column_name);
		});				
		//re-set column heights based on tallest column
		var highestCol = Math.max($('.column_1').height(),$('.column_2').height(),$('.column_1_2').height());
		$('.column_1, .column_2').height(highestCol);
		var array_columns_2 = ['.column_1', '.column_2', '.column_1_2'];
		$.each(array_columns_2, function(i, column_name) {
			$(column_name).children('.column_content').children('.column_sub_content').height(highestCol-68);
			$(column_name).children('.column_content').children('.column_footer').css('top', (highestCol-28) + 'px');
			$(column_name).height(highestCol + 10);//10 added to provide adequate space below submit button in footer
		});		
		//set height properties on lower column		
		if ($('.column_3').find('.column_title').length){
			single_column_height('.column_3');
		}else{
			$('.column_3').css('display', 'none');
		}
	}
	//set column height where three columns in row
	else if($(window).width() > s_tab) {
		//reset columns
		$('.column_3').css('display', 'block');
		//check max total height
			//set column heights independently
			var array_columns = ['.column_1', '.column_2', '.column_3', '.column_1_2'];
			$.each(array_columns, function(i, column_name) { 
				single_column_height(column_name);
			});				
			//re-set column heights based on tallest column
			var highestCol = Math.max($('.column_1').height(),$('.column_2').height(),$('.column_3').height(),$('.column_1_2').height());
			$('.column_1, .column_2, .column_3, .column_1_2').height(highestCol);
			var array_columns_2 = ['.column_1', '.column_2', '.column_3', '.column_1_2'];
			$.each(array_columns_2, function(i, column_name) {
				$(column_name).children('.column_content').children('.column_sub_content').height(highestCol-68);
				$(column_name).children('.column_content').children('.column_footer').css('top', (highestCol-28) + 'px');
				$(column_name).height(highestCol + 10);//10 added to provide adequate space below submit button in footer
			});
	}	
};

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



//variables for setting column widths - where 3 coloumns
var s_tab = '1240';
var mob = '720';
var limit = '310';

//Set size and location of elements depending on screen size	
	tab_format();
	tab_2_label_width();
	column_width(s_tab, mob, limit);//set column width depending on size of window
	column_height(s_tab, mob, limit);//set column height depending on size of window	
	column_width(s_tab, mob, limit);//set column width depending on size of window
	$(window).resize(function(){
		tab_format();
		tab_2_label_width();
		column_width(s_tab, mob, limit);//set column width depending on size of window
		column_height(s_tab, mob, limit);//set column height depending on size of window
		column_width(s_tab, mob, limit);//set column width depending on size of window
	});




});