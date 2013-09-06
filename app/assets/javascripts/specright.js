// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



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




$("#firstpane p.menu_head").click(function()
{
    $(this).css({backgroundImage:"url(feature.png) repeat-x"}).next("div.menu_body").slideToggle(300).siblings("div.menu_body").slideUp("slow");
    $(this).siblings().css({backgroundImage:"url(feature.png) repeat-x"});
});


//end
});                                                              