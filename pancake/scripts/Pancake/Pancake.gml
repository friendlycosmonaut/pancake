#macro BLANK_PIXEL spr_pixel
#macro INPUT global.input	
enum OnPressType {
	DoNothing,
	FlashColour,
	AnimateSprite,
	Bounce
}
enum ButtonState {
	Default,
	Hover,
	Pressing,
	Pressed
}

global.input = {
	update: function() {
		self.mouse_x = mouse_x;
		self.mouse_y = mouse_y;
		mouse_left = mouse_check_button(mb_left);
		mouse_right = mouse_check_button(mb_right);
		mouse_left_p = mouse_check_button_pressed(mb_left);
		mouse_right_p = mouse_check_button_pressed(mb_right);
		mouse_left_r = mouse_check_button_released(mb_left);
		mouse_right_r = mouse_check_button_released(mb_right);
	}
}
INPUT.update();	

function Pancake() constructor {
	stack = [];
	
	//Events
	static update = function() {
		update_children();	
	}
	static update_children = function() {
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var child = stack[i];
			//x, y, xscale, yscale, rotation, colour, alpha
			child.update_event(0, 0, 1, 1, 0, c_white, 1);
		}
	}
	static draw = function() {
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var child = stack[i];
			if(child.visible) {
				child.draw_event();
			}
		}
	}
	static initialise = function() {
		gui_width = display_get_gui_width();
		gui_height = display_get_gui_height();
	}
	static clear = function() {
		stack = [];	
	}

	static frame = function(x=0, y=0, width=1, height=1, rotation=0, alpha=1) {
		x *= gui_width;
		y *= gui_height;
		width *= gui_width;
		height *= gui_height;
		var new_frame = new __frame(x, y, width, height, rotation, alpha);
		new_frame.update_relative(0, 0, 1, 1, 0, c_white, 1);
		array_push(stack, new_frame);
		return new_frame;
	}
	
	initialise();
}

function __frame(x, y, width, height, rotation, alpha) constructor {
	active = true;
	visible = true;
	stack = [];
	anims = [];
	
	//Fields that change relative to our parents
	relative = {
		x: x,
		y: y,
		alpha: alpha,
		rotation: rotation,
		xscale: 1,
		yscale: 1
	}
	self.x = 0;
	self.y = 0;
	self.rotation = 0;
	self.alpha = 0;
	self.xscale = 1;
	self.yscale = 1;
	
	//Other fields
	self.width = width;
	self.height = height;
	self.colour = undefined;
	
	//Events
	static draw_event = function() {
		draw();
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var child = stack[i];
			child.draw_event();
		}
	}
	static draw = function() {}
	
	static update_event = function(x, y, xscale, yscale, rotation, alpha) {
		if(array_length(anims) > 0) {
			var anim = anims[0];
			//Will return 'true' when finished
			if(anim.run()) {
				array_delete(anims, 0, 1);	
			}
		}
		
		update_relative(x, y, xscale, yscale, rotation, alpha);
		update();
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var child = stack[i];
			child.update_event(self.x, self.y, self.xscale, self.yscale, self.rotation, self.alpha);
		}
	}
	static update = function() {}
	
	//Configure
	static add_child = function(child) {
		child.update_relative(self.x, self.y, self.xscale, self.yscale, self.rotation, self.alpha);
		array_push(stack, child);
	}
	///@func add_ease(ease_function, variable_name, start_value, end_value, seconds)
	static add_ease = function(ease_func, variable_name, start_value, end_value, seconds) {
		var struct = self;
		switch(variable_name) {
			case "y": 
			case "x":
			case "alpha":
			case "xscale":
			case "yscale":
				struct = relative; 
				break;
		}
		
		if(start_value == "current") {
			start_value = variable_struct_get(struct, variable_name);
		} else if(end_value == "current") {
			end_value = variable_struct_get(struct, variable_name);
		}
		add_anim(run_ease, seconds, end_value, [ease_func, variable_name, start_value, end_value]);
	}
	static run_ease = function(time_ratio, ease, variable_name, start_value, end_value) {
		var val = lerp(start_value, end_value, time_ratio) / abs(start_value-end_value);
		var result = ease(val);
		var corrected = lerp(start_value, end_value, result);
		print(val, start_value, end_value, time_ratio, result, corrected);
		
		var struct = self;
		switch(variable_name) {
			case "y": 
			case "x":
			case "alpha":
			case "xscale":
			case "yscale":
				struct = relative; 
				break;
		}
		variable_struct_set(struct, variable_name, corrected);
		return result;
	}
	///@func add_anim(function, seconds, end_result, arguments)
	static add_anim = function(func, seconds, end_result, arguments) {
		var anim = new Anim(self, func, seconds, end_result, arguments);
		array_push(anims, anim);
	}
	function Anim(owner, func, seconds, end_result, arguments) constructor {
		//We leave a place for the first entry to be the TIMER RATIO
		array_insert(arguments, 0, 0);
		self.owner = owner;
		self.timer = 0;
		self.func = func;
		self.end_time = seconds;
		self.end_result = end_result;
		self.arguments = arguments;
		//Our function for actually running the animation!
		static run = function() {
			self.timer += 1/60;
			self.arguments[0] = self.timer/self.end_time;
			var func = self.func;
			var args = self.arguments;
			with(self.owner) {
				var result = function_execute_alt(func, args);
			}
			return result == self.end_result;
		}	
	}
	
	//Functions
	static mouse_on = function(mouse_x, mouse_y, x, y) {
		return point_in_rectangle(mouse_x, mouse_y, x, y, x+self.width, y+self.height);
	}
	static update_relative = function(x, y, xscale, yscale, rotation, alpha) {
		self.x = self.relative.x + x;
		self.y = self.relative.y + y;
		
		self.rotation = self.relative.rotation * rotation;
		self.alpha = self.relative.alpha * alpha;
		self.xscale = self.relative.xscale * xscale;
		self.yscale = self.relative.xscale * yscale;
	}
	
	
	//Children Widgets
	///@func nineslice(spr, x_frac, y_frac, width_frac, height_frac, animate, frame, rotation, colour, alpha)
	static nineslice = function(spr, x=0, y=0, width=1, height=1, animate=false, frame=0, rotation=0, colour=c_white, alpha=1) {
		if(!sprite_get_nineslice(spr).enabled) {
			show_error("Tried to create ninelsice ui with sprite: "+sprite_get_name(spr), " however nineslice is not enabled.");
		}
		
		width *= self.width;
		height *= self.height;
		x *= self.width;
		y *= self.height;
		
		var child = new __sprite(spr, animate, x, y, width, height, frame, rotation, colour, alpha);
		add_child(child);
		return child;
	}
	///@func sprite(spr, x_frac, y_frac, animate, frame, rotation, colour, alpha)
	static sprite = function(spr, x=0, y=0, frame=0, animate=false, rotation=0, colour=c_white, alpha=1) {
		x *= self.width;
		y *= self.height;
		var child = new __sprite(spr, animate, x, y, undefined, undefined, frame, rotation, colour, alpha);
		add_child(child);
		return child;
	}
	///@func rectangle(x_frac, y_frac, width_frac, height_frac, colour, rotation, alpha)
	static rectangle = function(x=0, y=0, width=1, height=1, colour=c_white, rotation=0, alpha=1) {
		width *= self.width;
		height *= self.height;
		x *= self.width;
		y *= self.height;
		var child = new __rectangle(x, y, width, height, rotation, colour, alpha);
		add_child(child);
		return child;
	}
	///@func text(str, x_frac, y_frac, halign, valign, colour, font, width_frac, height_frac, alpha, line_separation)
	static text = function(str, x=0, y=0, halign=fa_left, valign=fa_top, colour=c_black, font=fnt_text, width=1, height=1, alpha, sep=1) {
		width *= self.width;
		height *= self.height;
		x *= self.width;
		y *= self.height;
		var child = new __text(str, font, x, y, width, height, colour, alpha, halign, valign, sep);
		add_child(child);
		return child;
	}
	///@func button(sprites, callback_function, arguments, x_frac, y_frac, rotation, colour, alpha)
	static button = function(sprites, callback, args=[], x=0, y=0, rot=0, colour=c_white, alpha=1) {
		x *= self.width;
		y *= self.height;
		var child = new __button(sprites, callback, args, x, y, rot, colour, alpha);
		add_child(child);
		return child;
	}
	///@func frame(x_frac, y_frac, width_frac, height_frac, rotation, alpha)
	static frame = function(x=0, y=0, width=1, height=1, rotation=0, alpha=1) {
		width *= self.width;
		height *= self.height;
		x *= self.width;
		y *= self.height;
		var child = new __frame(x, y, width, height, rotation, alpha);
		add_child(child);
		return child;
	}
}
function __sprite(spr, animate, x, y, width, height, anim_frame, rotation, colour, alpha) : __frame(x, y, width, height, rotation, alpha) constructor {
	self.spr = spr;
	self.frame = anim_frame;
	self.fspd = sprite_get_speed(spr)/60;
	self.max_frames = sprite_get_number(spr);
	self.animate = animate;
	self.colour = colour;
	
	self.spr_width = sprite_get_width(spr);
	self.spr_height = sprite_get_height(spr)
	
	static draw = function() {
		if(animate) {
			frame += self.fspd;
			if(frame >= max_frames) {
				frame = 0;	
			}
		}	
		
		var draw_xscale = xscale;
		var draw_yscale = yscale;
		
		if(self.width != undefined) draw_xscale *= width/spr_width;
		if(self.height != undefined) draw_yscale *= height/spr_height;
		draw_sprite_ext(spr, frame, x, y, draw_xscale, draw_yscale, rotation, colour, alpha);
	}
	static update = function() {

	}
}
function __rectangle(x, y, width, height, rotation, colour, alpha) : __frame(x, y, width, height, rotation, alpha) constructor {
	self.colour = colour;
	static draw = function() {
		draw_sprite_ext(BLANK_PIXEL, 0, x, y, width, height, rotation, self.colour, self.alpha);
	}
	static update = function() {}
}
function __text(str, font, x, y, width, height, colour, alpha, halign, valign, sep) : __frame(x, y, width, height, 1, 1, 0, alpha) constructor {
	self.str = str;
	self.font = font;
	self.halign = halign;
	self.valign = valign;
	self.colour = colour;
	
	draw_set_font(font);
	self.sep = string_height("M") * sep;
		
	static draw = function() {
		draw_set_font(font);
		draw_set_halign(halign);
		draw_set_valign(valign);
		draw_set_color(colour);
		draw_text_ext(x, y, str, sep, width);
	}
	static update = function() {}
}
function __button(sprite, callback, args, x, y, rotation, colour, alpha)  : __frame(x, y, 1, 1, rotation, alpha) constructor {
	self.sprite = sprite;
	
	self.callback = callback;
	self.args = args;
	self.colour = colour;
	
	//Does the button do anything when we click it?
	self.on_press_type = OnPressType.DoNothing;
	self.on_press_args = undefined;
	
	self.width = sprite_get_width(sprite);
	self.height = sprite_get_height(sprite);
	self.state = ButtonState.Default;
	
	//For hover animation
	self.frame = 0;
	self.fspd = sprite_get_speed(sprite)/60;
	self.max_frames = sprite_get_number(sprite);
	
	static set_on_press_type = function(type, args) {
		self.on_press_type = type;
		self.on_press_args = args;
	}
	static draw = function() {
		//The first frame is DEFAULT, middle frames are all hover animation, and last frame is PRESSED
		var index;
		switch(state) {
			case ButtonState.Default:
				index = 0;
				break;
			case ButtonState.Hover:
				frame += self.fspd;
				if(frame >= max_frames-1) {
					frame = 1;
				} 
				index = frame;
				break;
			case ButtonState.Pressing:
			case ButtonState.Pressed:
				index = max_frames - 1;
				break;
		}
		draw_sprite_ext(sprite, index, x, y, xscale, yscale, rotation, colour, alpha);
	}
	static update = function() {
		switch(state) {
			case ButtonState.Default:
				if(mouse_on(INPUT.mouse_x, INPUT.mouse_y, x, y)) {
					self.state = ButtonState.Hover;
					frame = 1;
				}
				break;
			case ButtonState.Hover:
				if(!mouse_on(INPUT.mouse_x, INPUT.mouse_y, x, y)) {
					self.state = ButtonState.Default;
				} else if(INPUT.mouse_left_p) {
					self.state = ButtonState.Pressing;
				}
				break;
			case ButtonState.Pressing:
				if(!mouse_on(INPUT.mouse_x, INPUT.mouse_y, x, y)) {
					self.state = ButtonState.Default;
				} else if(INPUT.mouse_left_r) {
					self.state = ButtonState.Pressed;
					if(self.callback != undefined) {
						function_execute_alt(self.callback, self.args);
					}
				}
				break;
				
			case ButtonState.Pressed:
				self.state = ButtonState.Hover;
				frame = 1;
				break;
		}
	}
}
