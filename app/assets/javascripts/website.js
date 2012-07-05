// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} });
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



Cufon.replace('#home_strapline, #menu_item, #home_intro_text, #foot_item, .feature_title, #option_title, .extra_questions_link, .large_trial_link_text_1, .small_trial_link_text, .feature_title_small', { fontFamily: 'TitilliumText25L_800'});
Cufon.replace('#home_intro_text, #home_intro_text_2, .login_submit', { fontFamily: 'TitilliumText25L_300'});


});                                                              