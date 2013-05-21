function user_edit_column_width() {
var label_width = $('.form_input_label').width();
var table_width = (460 - label_width);

	if($('.column_1, .column_3').find('table').width() < table_width) {
		$('.form_input').find('input[type=text], input[type=password]').css({'width':"225px"});
		$('.user_edit_note').css({'padding-left':"0px"});
	}
	else {
		$('.form_input').find('input[type=text], input[type=password]').css({'width':"210px"});
		$('.user_edit_note').css({'padding-left':"125px"});
	}

}


$(document).ready(function(){

//table input width for new user
	user_edit_column_width();
	$(window).resize(function(){
		user_edit_column_width();
	});	

//end
});
