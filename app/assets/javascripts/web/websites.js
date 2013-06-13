//function for setting column width depending on size of window	
function web_sub_column_width(s_tab, mob, limit) {

	var s_tab = s_tab;
	var mob = mob;
	var limit = limit;

	var window_width = $(window).width();

	if(window_width <= mob) {
		var web_sub_col_width = (window_width -60);
		$('.web_sub_column_1, .web_sub_column_2, .web_sub_column_3').css({'width': web_sub_col_width +"px"});
		$('.web_sub_column_1, .web_sub_column_2, .web_sub_column_3').css('height','auto');
	}else if(window_width > mob) {
		var web_sub_col_width = (window_width -144)/3;
  		$('.web_sub_column_1, .web_sub_column_2, .web_sub_column_3').css({'width': web_sub_col_width +"px"});
  		var highestCol = Math.max($('.web_sub_column_1').height(),$('.web_sub_column_2').height(),$('.web_sub_column_3').height())
		$('.web_sub_column_1, .web_sub_column_2, .web_sub_column_3').height(highestCol);
	}
}



function web_main_column_width(s_tab, mob, limit) {

	var s_tab = s_tab;
	var mob = mob;
	var limit = limit;

	var window_width = $(window).width();
	var index_width = $('.web_page_body').width();

	if(window_width <= mob) {
		var web_col_width = (index_width -40);
		$('.web_main_column_1, .web_main_column_2').css({'width': web_col_width +"px"});
		$('.web_home_img').css({'max-height': '200px'});
		$('.web_main_column_1').css({'height': '200px'});
		var image_margin = ((web_col_width+20) - (200*3)/2)/2;
		$('.web_home_image').css({'margin-left': image_margin + 'px'});
	}else if(window_width > mob) {
		var web_col_width = (index_width -80)/2;
  		$('.web_main_column_1, .web_main_column_2').css({'width': web_col_width +"px"});
  		var web_home_image_width = (index_width -80)/2;
  		$('.web_home_image').css({'width': web_home_image_width + 'px', 'height': web_home_image_width + 'px'});	
	
		var highestCol = $('.web_main_column_2').height();
		$('.web_main_column_1').css({'height': highestCol + 'px'});
		$('.web_home_img').css({'max-height': highestCol + 'px'});
			
		if(web_col_width < (highestCol*3)/2) {
			$('.web_home_img').css({'max-width': web_col_width + 'px', 'margin-left': '0px'});
			$('.web_home_image').css({'margin-left': '0px'});
		}else{
			var image_margin = ((web_col_width + 20) - (highestCol*3)/2)/2;
			$('.web_home_image').css({'margin-left': image_margin + 'px'});			
		}		
	}		 	
}

function web_signup_link(){
	var index_width = $('.web_main_column_2').width();
	var signup_width = $('.web_signup_link').width();
	var link_margin = ((index_width - signup_width)-30)/2;
	$('.web_signup_link').css({'margin-left': link_margin + 'px'});	
}

function web_tagline(){
	var index_width = $('.web_main_column_2').width();
	var signup_width = $('.web_tagline_text').width();
	var link_margin = ((index_width - signup_width))/2;
	$('.web_tagline_text').css({'margin-left': link_margin + 'px'});	
}

function web_feature_menu_small(){
	var index_width = $('.web_feature_index_small').width();
	var menu_item_width = 134;
	var n = $(".web_feature_menu_item_small").length;
	var no_items_width = index_width/menu_item_width;
	var no_items_rounded = Math.ceil(no_items_width);
	if(n >= no_items_rounded){
		var menu_div_margin = (index_width - (menu_item_width*(no_items_rounded - 1)))/2;
		$('div.web_feature_index_small_container').css({'margin-left': menu_div_margin +'px', 'margin-right': menu_div_margin +'px'});
	}else{
		var menu_div_margin = (index_width - (n*menu_item_width))/2;
		$('div.web_feature_index_small_container').css({'margin-left': menu_div_margin +'px', 'margin-right': menu_div_margin +'px'});		
	}
}

function web_feature_menu_large(){
	var index_width = $('.web_feature_index_large').width();
	var menu_item_width = 274;
	var no_items_width = index_width/menu_item_width;
	var no_items_rounded = Math.ceil(no_items_width);
	var menu_div_margin = (index_width - (menu_item_width*(no_items_rounded - 1)))/2;
	$('div.web_feature_index_large_container').css({'margin-left': menu_div_margin +'px', 'margin-right': menu_div_margin +'px'});
}

function web_posts_index(s_tab, mob, limit){
	var s_tab = s_tab;
	var mob = mob;
	var limit = limit;

	var window_width = $(window).width();
	var posts_width = $('.web_blog_content').width();

	if(window_width >= mob) {		
		var blog_index_width = $('.web_blog_index').width();
		var posts_width_total = (posts_width - blog_index_width - 80);	
		$('.web_blog_posts').width(posts_width_total);
		$('.comment_content').width(posts_width_total-30);
		$('.web_blog_index, .blog_index_options').width(220);
	}else{
		$('.web_blog_posts').width(posts_width-40);
		$('.comment_content').width(posts_width-60);
		$('.web_blog_index, .blog_index_options').width(posts_width-40);	
	}
}


$(document).ready(function(){



//variables for setting column widths - where 3 coloumns
var s_tab = '1240';
var mob = '720';
var limit = '310';

//Set size and location of elements depending on screen size	
	web_sub_column_width(s_tab, mob, limit);//set column width depending on size of window
	web_main_column_width(s_tab, mob, limit);//set column width depending on size of window
	web_sub_column_width(s_tab, mob, limit);//repeat required to get sizes right on initial load - not sure why
	web_main_column_width(s_tab, mob, limit);//repeat required to get sizes right on initial load - not sure why
	web_feature_menu_small();
	web_feature_menu_large();
	web_signup_link();
	web_tagline();
	web_posts_index(s_tab, mob, limit);
	$(window).resize(function(){
		web_sub_column_width(s_tab, mob, limit);//set column width depending on size of window
		web_main_column_width(s_tab, mob, limit);//set column width depending on size of window
		web_sub_column_width(s_tab, mob, limit);//repeat required to get sizes right on initial load - not sure why
		web_feature_menu_small();
		web_feature_menu_large();
		web_signup_link();
		web_tagline();
		web_posts_index(s_tab, mob, limit);
	});



//show/hide website mobile menu settings menu
	$('nav.web_menu_mob').click(function (){
		$('nav.web_mob_menu').toggle();
	});
  

	$('nav.web_mob_menu').mouseleave(function (){
		$(this).hide();
	});

//faq accordian js 
	$('.firstpane p.faq_menu_head').click(function(){
    	$(this).css({'background-color': '#f6f6f6'}).next('div.faq_menu_body').slideToggle(300).siblings('div.faq_menu_body').slideUp('slow');
    	$(this).siblings().css({'background-color': '#f6f6f6'});
	});




});