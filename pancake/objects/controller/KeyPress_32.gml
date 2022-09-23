var a, spd;
if(menu_showing) {
	a = 0.8;
	spd = 1;
	phone_frame.add_ease(ease_in_out_back, "top", 0, a, spd, true);
	phone_frame.join_ease(ease_in_out_back, "bottom", 0, -a, spd, true);
	
	a = 0.88;
	panel_frame.add_ease(ease_in_out_back, "top", 0, -a, spd, true);
	panel_frame.join_ease(ease_in_out_back, "bottom", 0, a, spd, true);
} else {
	a = 0.8;
	spd = 1;
	phone_frame.add_ease(ease_in_out_back, "top", 0, -a, spd, true);
	phone_frame.join_ease(ease_in_out_back, "bottom", 0, a, spd, true);	
	
	a = 0.88;
	panel_frame.add_ease(ease_in_out_back, "top", 0, a, spd, true, spd*0.75);
	panel_frame.join_ease(ease_in_out_back, "bottom", 0, -a, spd, true, spd*0.75);
}
menu_showing = !menu_showing;