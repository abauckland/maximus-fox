$(document).ready(function(){



//data download clause select
$('input#data_clauses').click(function (){
  $('select#clause_ids').removeAttr('disabled');
    $('div.column_sub_form').find('td').css('color', '#000');
});

$('input#data_template, input#data_company_template').click(function (){
  $('select#clause_ids').attr('disabled', 'disabled');
  $('div.column_sub_form').find('td').css('color', '#a5a5a5');
});

//size select window in column form
var available_width = $('.column_form').width();
var select_width = (available_width - 40);

$('.column_sub_form').find('select').css({'width': select_width + "px"});


//end
});
