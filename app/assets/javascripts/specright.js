// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

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



//following jquery loads after DOM is ready
$(document).ready(function(){

$('.login').focus(function(){
    if (this.value == this.defaultValue) {
        this.value = '';
        $(this).removeClass('default');
    };
});

$('.login').blur(function(){
    if (this.value == '') {
        this.value = this.defaultValue;
        $(this).addClass('default');
    };
});




//login text and password field
var $password = $('#login_email');
        $password.hide(); //hide input with type=password

        $("#login_email_default").click(function() {
                $( this ).hide();
                $('#login_email').show();
                $('#login_email').focus();
        });

$('#login_email').focusout(function() {
    if ($(this).val().length === 0) { //if password field is empty            
        $(this).hide();
        $('#login_email_default').show();
        $('#login_email_default').default_value('Enter a password'); //will clear on click
    }
});



var $password = $('#password');
        $password.hide(); //hide input with type=password

        $("#password_instructions").click(function() {
                $( this ).hide();
                $('#password').show();
                $('#password').focus();
        });

$('#password').focusout(function() {
    if ($(this).val().length === 0) { //if password field is empty            
        $(this).hide();
        $('#password_instructions').show();
        $('#password_instructions').default_value('Enter a password'); //will clear on click
    }
});



$("#firstpane p.menu_head").click(function()
{
    $(this).css({backgroundImage:"url(feature.png) repeat-x"}).next("div.menu_body").slideToggle(300).siblings("div.menu_body").slideUp("slow");
    $(this).siblings().css({backgroundImage:"url(feature.png) repeat-x"});
});
//end of wen site jquery


//sets up the tabs for the edit window
$("#usual1 ul").idTabs("!mouseover");

//sets revision window height based on window size
$(function(){
  $('.edit_box').css({'height':(($(window).height())-170)+"px"});
  $(window).resize(function(){
  $('.edit_box').css({'height':(($(window).height())-170)+"px"});
  });
});

//sets revision window height based on window size
$(function(){
  $('#new_project_details, #revision_help_draft').css({'height':(($(window).height())-190)+"px"});
  $(window).resize(function(){
  $('#new_project_details, #revision_help_draft').css({'height':(($(window).height())-190)+"px"});
  });
});

//sets revision window height based on window size
$(function(){
  $('#edit_box_print').css({'height':(($(window).height())-235)+"px"});
  $(window).resize(function(){
  $('#edit_box_print').css({'height':(($(window).height())-235)+"px"});
  });
});

//sets revision window height based on window size
$(function(){
  $('#line1').css({'height':(($(window).height())-115)+"px"});
  $(window).resize(function(){
  $('#line1').css({'height':(($(window).height())-115)+"px"});
  });
});



//sets revision window width based on window size                                                                   
$(function(){                                                      
  $('.edit_box, .edit_box_2, #revision_help_draft').css({'width':(($(window).width())-32)+"px"});                                                                 
  $(window).resize(function(){                                     
  $('.edit_box, .edit_box_2, #revision_help_draft').css({'width':(($(window).width ())-32)+"px"});
  });
});

var minWidth = '1000';


$(function(){                                                      
  $('#header').css({'width':($(window).width()-30)+"px"});                                                                 
  $(window).resize(function(){
  if($(window).width() >= minWidth)
  {$('#header').css({'width':($(window).width()-30)+"px"});}
  else
  {$('#header').css({'width': (minWidth - 30)+"px"});}  
  });
});


$(function(){                                                      
  $('#project_info, div.usual, #edit_box_full, #edit_box_less, #edit_box, #edit_box_half, #bottom_form').css({'width':(($(window).width())-60)+"px"});                                                                 
  $(window).resize(function(){                                     
  if($(window).width() >= minWidth)
  {$('#project_info, div.usual, #edit_box_full, #edit_box_less, #edit_box, #edit_box_half, #bottom_form').css({'width':($(window).width()-60)+"px"});}
  else
  {$('#project_info, div.usual, #edit_box_full, #edit_box_less, #edit_box, #edit_box_half, #bottom_form').css({'width': (minWidth - 60)+"px"});}  
  });                         
});

$(function(){                                                      
  $('#option_band').css({'width':(($(window).width())-70)+"px"});                                                                 
  $(window).resize(function(){                                     
  if($(window).width() >= minWidth)
  {$('#option_band').css({'width':($(window).width()-70)+"px"});}
  else
  {$('#option_band').css({'width': (minWidth - 70)+"px"});}  
  });
});


//size of subsection anc clause add/remove pages 
$(function(){                                                      
  $('#project_subsections, #template_subsections, #project_clauses, #template_clauses').css({'width':((($(window).width())-90)/2 - 100)+"px"});                                                                 
  $(window).resize(function(){                                     
  if($(window).width() >= minWidth)
  {$('#project_subsections, #template_subsections, #project_clauses, #template_clauses').css({'width':((($(window).width())-90)/2 - 100)+"px"});}
  else
  {$('#project_subsections, #template_subsections, #project_clauses, #template_clauses').css({'width': ((minWidth -90)/2 - 100)+"px"});}  
  });
});

$(function(){                                                      
  $('#template_subsections, #project_subsections, #project_clauses, #template_clauses').attr('size', (($(window).height())-304)/16);                                                              
  $(window).resize(function(){                                     
  $('#template_subsections, #project_subsections, #project_clauses, #template_clauses').attr('size', (($(window).height())-304)/16);
  });
});





//sets revision window width based on window size                                                                   
$(function(){                                                      
  $('#loadingdiv').css({'left':((($(window).width())/2)-50)+"px"});                                                                 
  $(window).resize(function(){                                     
  $('#loadingdiv').css({'left':((($(window).width())/2)-50)+"px"});
  });
});

$(function(){                                                      
  $('#loadingdiv').css({'top':((($(window).height())/2)-25)+"px"});                                                                 
  $(window).resize(function(){                                     
  $('#loadingdiv').css({'top':((($(window).height())/2)-25)+"px"});
  });
});






$(function(){                                                      
  $('#new_prj_details_1, #new_prj_details_2, #new_prj_details_3, #new_prj_details_4, #prj_details_1, #prj_details_2, #prj_details_3, #prj_details_4').css({'width':(($(window).width())-60)+"px"});                                                                 
  $(window).resize(function(){                                     
  $('#new_prj_details_1, #new_prj_details_2, #new_prj_details_3, #new_prj_details_4, #prj_details_1, #prj_details_2, #prj_details_3, #prj_details_4').css({'width':(($(window).width())-60)+"px"});
  });
});


//MOB sets revision window width based on window size                                                                   
$(function(){                                                      
  $('form.user_new').children('#user_submit').css({'width':(($(window).width())-40)+"px"});                                                                 
  $(window).resize(function(){                                     
  $('form.user_new').children('#user_submit').css({'width':(($(window).width())-40)+"px"});
  });
});

$(function(){                                                      
  $('#specline_submit').css({'width':(($(window).width())-40)+"px"});                                                                 
  $(window).resize(function(){                                     
  $('#specline_submit').css({'width':(($(window).width())-40)+"px"});
  });
});


//jeditbale functions
$.editable.addInputType('autogrow', {
                element : function(settings, original) {
                    var textarea = $('<textarea />');
                    if (settings.rows) {
                        textarea.attr('rows', settings.rows);
                    } else if (settings.height != "none") {
                        textarea.height(settings.height);
                    }
                    if (settings.cols) {
                        textarea.attr('cols', settings.cols + 10);
                    } else if (settings.width != "none") {
                    	if (settings.width > (textarea.width(($(window).width())-330))){
                        textarea.width(settings.width + 10);
                       }
                       else{
                       	var test_1 = settings.id;
                       	textarea.width(($(window).width()) - ($('table#' + test_1 + ' span.editable_text3').width()) - ($('table#' + test_1 + ' span.new_editable_text3').width())- 328);
                       }
                    }
                    textarea.css("font", "normal 13px arial");
                    $(this).append(textarea);
                    return(textarea);
                },
                plugin : function(settings, original) {
        $('textarea', this).autogrow(settings.autogrow);
    }
});



$('.editable_text3').mouseover(function(){
var spec_id = $(this).attr('id');
$(this).editable('/speclines/'+spec_id+'/update_specline_3', {id: spec_id, type: 'text', onblur: 'submit', method: 'PUT', indicator: 'Saving..', submitdata: {_method: 'put', 'id': '<%= @line.id%>', authenticity_token: AUTH_TOKEN}});    
}); 
$('.editable_text4').mouseover(function(){
var spec_id = $(this).attr('id');
$(this).editable('/speclines/'+spec_id+'/update_specline_4', {id: spec_id, type: 'autogrow', onblur: 'submit', method: 'PUT', indicator: 'Saving..', autogrow : {lineHeight : 16, maxHeight  : 512}, submitdata: {_method: 'put', 'id': '<%= @line.id%>', authenticity_token: AUTH_TOKEN}});    
}); 
$('.editable_text5').mouseover(function(){
var spec_id = $(this).attr('id');
$(this).editable('/speclines/'+spec_id+'/update_specline_5', {id: spec_id, type: 'autogrow', onblur: 'submit', method: 'PUT', indicator: 'Saving..', autogrow : {lineHeight : 16, maxHeight  : 512}, submitdata: {_method: 'put', 'id': '<%= @line.id%>', authenticity_token: AUTH_TOKEN}});    
});    
$('.editable_text6').mouseover(function(){
var spec_id = $(this).attr('id');
$(this).editable('/speclines/'+spec_id+'/update_specline_6', {id: spec_id, type: 'text', onblur: 'submit', method: 'PUT', indicator: 'Saving..', submitdata: {_method: 'put', 'id': '<%= @line.id%>', authenticity_token: AUTH_TOKEN}});    
});    


//show/hide user settings menu
$('div#user_name').click(function (){
  $('div#user_menu').toggle();
});
  
$('div#header').mouseover(function (){
  $('div#user_menu').hide();
});

$('div#user_menu').mouseleave(function (){
  $(this).hide();
});



//show/hide functions for spec and clause lines
$('tr.specline_row').hover(function (){
  $(this).children('td.specline_link').show();
    $(this).children('td.pad').children('img').show();
  $(this).children('td.padding').hide();
  $(this).css('background-color', '#efefef');
  },
  function (){
  $(this).children('td.specline_link').hide();
      $(this).children('td.pad').children('img').hide();
  $(this).children('td.padding').show();
  $(this).css('background-color', '#ffffff');
  }
);

//show/hide functions for rev lines
$('tr.rev_row, tr.rev_row_strike, tr.clause_title_2').hover(function (){
  $(this).children('td.specline_link').toggle();
  $(this).children('td.padding').toggle();
  $(this).css('background-color', '#efefef');
  },
  function (){
  $(this).children('td.specline_link').toggle();
  $(this).children('td.padding').toggle();
  $(this).css('background-color', '#ffffff');
  }
);



$('.submittable').live('change', function() {
 $(this).closest('form#new_clause').submit();
   return false;
});

$('.submittable2').live('click', function() {
 $(this).parents('form:first').submit();
   return false;
});



//loads ajax functionality to links with specified class
ajaxLinks();

//sortable test
$('.1, .2, .3, .4, .5, .6, #prelim_show').sortable({
 axis: 'y',
 cancel: '.clause_title, span',
 cursor: 'pointer',
 handle: 'td.pad img',
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


jQuery.ajaxSetup({
  beforeSend: function() {
     $('#loadingdiv').fadeIn(400)
  },
  complete: function(){
     $('#loadingdiv').hide()
  },
  success: function() {
  	 $('#loadingdiv').hide()
  }
}); 

$('#section_select').change(function () {
  $('td.dg_title_subsection').hide()
  $('select:#subsection').hide()
  });


$('.project_tab, .document_tab, .rev_tab, .print_tab, a.new_project_link, input:submit').click(function () {
     $('#loadingdiv').show().delay(10000).fadeOut(0)
  });
  
$('.project_select, select#section, select#subsection').change(function () {
     $('#loadingdiv').show()
  });  

$('input#user_role_user').click(function (){
  $('select#user_id').removeAttr('disabled');
});

$('input#user_role_admin').click(function (){
  $('select#user_id').attr('disabled', 'disabled');
});


$('input#project_submit').click(function () {
     $('#loadingdiv').show()
  });

$('a.get, a.delete, a[title]').tipsy();





$('tr#clause_row').click(function (){
if($(this).children('td').children('input[type=checkbox]').attr('checked') != false)
{
$(this).css('background-color', '#efefef');
$(this).children('td').children('input[type=checkbox]').attr('checked', false);
}
else
{
$(this).css('background-color', '#bbb');
$(this).children('td').children('input[type=checkbox]').attr('checked', true);
}
});

$('select#project').selectBox();
$('select#project_id').selectBox();
$('select#section, select#subsection').selectBox();
$('select#revision').selectBox();
$('select#selected_template_id').selectBox();




//manage subsections
$('#add_some').click(function() {
$('select#template_subsections > option:selected').appendTo('select#project_subsections');
});

$('#add_all').click(function() {
$('select#template_subsections > option').appendTo('select#project_subsections');
});

$('#remove_some').click(function() {
$('select#project_subsections > option:selected').appendTo('select#template_subsections');
});

$('#remove_all').click(function() {
$('select#project_subsections > option').appendTo('select#template_subsections');
});


$('input.edit_submit').click(function() {
	$('select#project_subsections').each(function(){
	$('select#project_subsections option').attr('selected','true'); });
}) ; 

//manage clauses
$('#add_some').click(function() {
$('select#template_clauses > option:selected').appendTo('select#project_clauses');
});

$('#add_all').click(function() {
$('select#template_clauses > option').appendTo('select#project_clauses');
});

$('#remove_some').click(function() {
$('select#project_clauses > option:selected').appendTo('select#template_clauses');
});

$('#remove_all').click(function() {
$('select#project_clauses > option').appendTo('select#template_clauses');
});


$('input.edit_submit').click(function() {
	$('select#project_clauses').each(function(){
	$('select#project_clauses option').attr('selected','true'); });
}) ;


//new clause title template select
$('input#clause_content_clone_content').click(function (){
  $('select#clone_template_id').removeAttr('disabled');
  $('select#clone_clause_id').removeAttr('disabled');
    $('#clone_select td').css('color', '#000');
});

$('input#clause_content_no_content, input#clause_content_blank_content').click(function (){
  $('select#clone_template_id').attr('disabled', 'disabled');
  $('select#clone_clause_id').attr('disabled', 'disabled');
  $('#clone_select td').css('color', '#7b7b7b');
});


$("#clone_template_id").change(function() {
    var template = $('select#clone_template_id :selected').val();
    jQuery.get('/clauses/'+ template + '/update_clause_select');
});



Cufon.replace('#home_strapline');

//end
});                                                              