amount = 0.9
spd = 1
if(menu_showing) {
	menu_frame.add_ease(ease_in_out_back, "top", 0, -amount, spd, true);
	menu_frame.join_ease(ease_in_out_back, "bottom", 0, amount, spd, true);
	
	menu_frame.add_ease(ease_in_out_back, "top", 0, amount, spd, true);
	menu_frame.join_ease(ease_in_out_back, "bottom", 0, -amount, spd, true);
} else {
	menu_frame.add_ease(ease_in_out_back, "top", 0, amount, spd, true);
	menu_frame.join_ease(ease_in_out_back, "bottom", 0, -amount, spd, true);	
	
}