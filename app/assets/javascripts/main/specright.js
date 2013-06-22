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


//new clause reference field
var $enter_clause_ref = $('#enter_clause_ref');
        $enter_clause_ref.hide(); //hide input with type=password

        $("#enter_clause_ref_default").click(function() {
                $( this ).hide();
                $('#enter_clause_ref').show();
                $('#enter_clause_ref').focus();
        });

$('#enter_clause_ref').focusout(function() {
    if ($(this).val().length === 0) { //if password field is empty            
        $(this).hide();
        $('#enter_clause_ref_default').show();
        $('#enter_clause_ref_default').default_value('????'); //will clear on click
    }
});




$("#firstpane p.menu_head").mouseover(function()
{
    $(this).css({backgroundImage:"url(feature.png) repeat-x"}).next("div.menu_body").show();
    $(this).siblings().css({backgroundImage:"url(feature.png) repeat-x"});
});
$("#firstpane p.menu_head").mouseout(function()
{
    $(this).css({backgroundImage:"url(feature.png) repeat-x"}).next("div.menu_body").hide();
    $(this).siblings().css({backgroundImage:"url(feature.png) repeat-x"});
});
//end of web site jquery


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
//!!the following code prevented jeditable from working in jquery 1.7 but ok in 1.3 - no idea why!
//                plugin : function(settings, original) {
//        $('textarea', this).autogrow(settings.autogrow);
//    }
});






//loads ajax functionality to links with specified class
ajaxLinks();


//show/hide functions for spec and clause lines





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

$('select#template_sections').selectBox();
$('select#project_sections').selectBox();



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


$("#firstpane p.menu_head").click(function()
{
    $(this).css({backgroundImage:"url(feature.png) repeat-x"}).next("div.menu_body").slideToggle(300).siblings("div.menu_body").slideUp("slow");
    $(this).siblings().css({backgroundImage:"url(feature.png) repeat-x"});
});



Cufon.replace('.home_strapline, .mob_strapline, .menu_item, .home_intro_text, .feature_title, #option_title, .extra_questions_link, .large_trial_link_text_1, .small_trial_link_text, .feature_title_small', { fontFamily: 'TitilliumText25L_800'});
Cufon.replace('.home_intro_text, #home_intro_text_2, .login_submit', { fontFamily: 'TitilliumText25L_300'});

//end
});                                                              