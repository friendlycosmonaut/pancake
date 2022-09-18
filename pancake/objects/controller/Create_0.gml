
pancake = new Pancake();
menu_frame = pancake.frame(0.15, 0.2, 0.15, 0.2);

menu_frame.button(spr_ui_exit, function() {
	show_debug_message("exit menu!");
}, undefined, 1.01);

/////////PHONE
var phone_frame = menu_frame.frame(0, 0, 0.76, 0);
phone_frame.nineslice(spr_ui_slice_pink);

var phone_display = phone_frame.frame(0.1, 0.1, 0.1, 0.15);
phone_display.nineslice(spr_ui_slice_blue);

/////////MENU
////NAME
var name_frame = menu_frame.frame(0.25, 0, 0, 0.8);
name_frame.nineslice(spr_ui_slice_blue);
name_frame.text("Name: ", 0.05, 0.5, fa_left, fa_middle);
name_frame.rectangle(0.2, 0.2, 0.1, 0.2, c_white);
name_frame.text("Captain Bunbun", 0.25, 0.5, fa_left, fa_middle);

////CHARACTER
var character_frame = menu_frame.frame(0.25, 0.21, 0, 0);
character_frame.nineslice(spr_ui_slice_purple);
character_frame.text("My New Beginning", 0.5, 0.05, fa_middle);

character_frame.rectangle(0.05, 0.2, 0.8, 0.4, merge_colour(c_white, c_orange, 0.1));

//Loop over to draw buttons
var options = ["Skin", "Eyes", "Mouth", "Hair", "Shirt", "Pants", "Shoes"];
var len = array_length(options)
var columns = 2;
var total_width = 0.6;
var total_height = 0.6; 
var column_width = total_width/columns;
var half = ceil(len * 0.5);
var start_x = 0.3;
var start_y = 0.2;
for(var i = 0; i < len; i++) {
	var xx = start_x + ((i div half) * column_width);
	var yy = start_y + ((i mod half) * (total_height / half));
	
	var option = options[i];
	character_frame.button(spr_ui_button_left, function(option) {
		print(option, "left");
	}, [option], xx, yy);
	
	var x_sep = 0.05;
	character_frame.text(option, xx + x_sep, yy);
	character_frame.button(spr_ui_button_right, function(option) {
		print(option, "right");
	}, [option], xx + column_width - (x_sep*2), yy);
}

character_frame.text("Don't worry, you can make changes in your life whenever you like!", 0.5, 0.95, fa_middle, fa_bottom);

/////////INVENTORY
var inventory_frame = pancake.frame(0.1, 0.9, 0.1, 0);
inventory_frame.nineslice(spr_ui_slice_pink);