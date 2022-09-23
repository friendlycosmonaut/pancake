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
		self.mouse_left = mouse_check_button(mb_left);
		self.mouse_right = mouse_check_button(mb_right);
		self.mouse_left_p = mouse_check_button_pressed(mb_left);
		self.mouse_right_p = mouse_check_button_pressed(mb_right);
		self.mouse_left_r = mouse_check_button_released(mb_left);
		self.mouse_right_r = mouse_check_button_released(mb_right);
	}
}
INPUT.update();	

function Pancake() constructor {
	stack = [];
	
	//Events
	static update = function() {
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var child = stack[i];
			//x, y, width, height, rotation, colour, alpha
			child.update_event(0, 0, gui_width, gui_height, 0, c_white, 1);
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

	static frame = function(left=0, top=0, right=0, bottom=0, rotation=0, alpha=1) {
		var new_frame = new __frame(left, top, right, bottom, rotation, alpha);
		array_push(stack, new_frame);
		return new_frame;
	}
	
	initialise();
}

function __frame(left, top, right, bottom, rotation, alpha) constructor {
	visible = true;
	active = true;
	
	stack = [];
	eases = [];
	
	//Fields that change relative to our parents
	self.x = 0;
	self.y = 0;
	self.width = 0;
	self.height = 0;
	self.use_scale = false;
	
	self.left = left;
	self.top = top;
	self.right = right;
	self.bottom = bottom;
	self.rotation = rotation;
	self.alpha = alpha;
	
	//Other fields
	self.colour = c_white;
	
	//////Events
	static draw_event = function() {
		draw();
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var child = stack[i];
			child.draw_event();
		}
	}
	static draw = function() {}
	static update_event = function(x, y, width, height, rotation, alpha) {
		var anims_total = array_length(eases);
		if(anims_total > 0) {
			var c = array_length(eases[0]);
			for(var i = c-1; i >= 0; i--) {
				var anim = eases[0][i];
				//Will return 'true' when finished
				if(anim.run()) {
					array_delete(eases[0], i, 1);
				}
			}
			if(array_length(eases[0]) == 0) {
				array_delete(eases, 0, 1);	
			}
		}
		
		update_pos(x, y, width, height, rotation, alpha);
		update();
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var child = stack[i];
			child.update_event(self.x, self.y, self.width, self.height, self.rotation, self.alpha);
		}
	}
	static update = function() {}
	
	//////Configure
	static add_child = function(child) {
		array_push(stack, child);
	}
	///@func join_ease(ease_function, variable_name, start_value, end_value, seconds, relative, delay)
	static join_ease = function(ease_func, variable_name, start_value, end_value, seconds, relative=false, delay=0) {		
		var anim = new Ease(self, relative, seconds, delay, [ease_func, variable_name, start_value, end_value]);
		var c = array_length(eases)-1;
		array_push(eases[c], anim);
	}
	///@func add_ease(ease_function, variable_name, start_value, end_value, seconds, relative, delay)
	static add_ease = function(ease_func, variable_name, start_value, end_value, seconds, relative=false, delay=0) {
		var anim = new Ease(self, relative, seconds, delay, [ease_func, variable_name, start_value, end_value]);
		array_push(eases, [anim]);
	}
	
	function Ease(owner, relative, seconds, delay, arguments) constructor {
		self.owner = owner;
		self.timer = 0;
		self.end_time = seconds;
		self.relative = relative;
		
		//Delay
		self.delay = delay;
		self.delay_timer = 0;
		
		//We leave a place for the first entry to be the TIMER RATIO
		array_insert(arguments, 0, 0);
		self.arguments = arguments;
		self.initialised = false;
		//Our function for actually running the animation!
		
		static init = function() {
			if(!self.initialised) {
				if(self.delay_timer >= self.delay) {
					self.initialised = true;
					if(self.relative) {
						var variable_name = self.arguments[2];
						var current = variable_struct_get(self.owner, variable_name);
						//start value
						self.arguments[3] += current;
						//end value
						self.arguments[4] += current;	
					}	
				} else {
					self.delay_timer += 1/60;	
				}
			}
			return self.initialised;
		}
		static run_ease = function(time_ratio, ease, variable_name, start_value, end_value) {
			var dist = abs(end_value - start_value)
			var val = (dist * time_ratio)/dist
			var result = ease(val);
			var corrected = lerp(start_value, end_value, result);
			//The "self" here will be the owner
			variable_struct_set(self, variable_name, corrected);
			return result;
		}
		
		static run = function() {
			if(self.init()) {
				self.timer += 1/60;
				self.arguments[0] = self.timer/self.end_time;
				var func = self.run_ease;
				var args = self.arguments;
				with(self.owner) {
					function_execute_alt(func, args);
				}
			}
			return self.timer >= self.end_time;
		}	
	}
	
	//////Functions
	static mouse_on = function(mouse_x, mouse_y, x, y) {
		var x2, y2;
		if(self.use_scale) {
			x2 = x + (self.xscale * self.spr_width);
			y2 = y + (self.yscale * self.spr_height);
		} else {
			x2 = x + self.width;
			y2 = y + self.height;	
		}
		return point_in_rectangle(mouse_x, mouse_y, x, y, x2, y2);	
	}
	static update_pos = function(x, y, width, height, rotation, alpha) {
		self.x = x + (self.left * width);
		self.y = y + (self.top * height);
		
		if(self.use_scale) {
			
		} else {
			self.width = width - ((self.right + self.left) * width);
			self.height = height - ((self.bottom + self.top) * height); 
		}
	}
	
	//Children Widgets
	///@func nineslice(spr, left, top, right, bottom, animate, frame, rotation, alpha)
	static nineslice = function(spr, left=0, top=0, right=0, bottom=0, animate=false, frame=0, rotation=0, alpha=1) {
		if(!sprite_get_nineslice(spr).enabled) {
			show_error("Tried to create ninelsice ui with sprite: "+sprite_get_name(spr), " however nineslice is not enabled.");
		}
		
		var child = new __nineslice(spr, animate, left, top, right, bottom, frame, rotation, alpha);
		add_child(child);
		return child;
	}
	///@func sprite(spr, x_frac, y_frac, xscale, yscale, animate, frame, rotation, alpha)
	static sprite = function(spr, left=0, top=0, xscale=1, yscale=1, animate=false, frame=0, rotation=0, alpha=1) {
		var child = new __sprite(spr, animate, left, top, 0, 0, xscale, yscale, frame, rotation, alpha);
		add_child(child);
		return child;
	}
	///@func rectangle(left, top, right, bottom, colour, rotation, alpha)
	static rectangle = function(left=0, top=0, right=0, bottom=0, colour=c_white, rotation=0, alpha=1) {
		var child = new __rectangle(left, top, right, bottom, rotation, colour, alpha);
		add_child(child);
		return child;
	}
	///@func text(str, left, top, halign, valign, colour, font, alpha, line_separation)
	static text = function(str, left=0, top=0, halign=fa_left, valign=fa_top, colour=c_black, font=fnt_text, alpha, sep=1) {
		var child = new __text(str, font, left, top, colour, alpha, halign, valign, sep);
		add_child(child);
		return child;
	}
	///@func button(sprites, callback_function, arguments, left, top, xscale, yscale, rotation, alpha)
	static button = function(sprites, callback, args=[], left=0, top=0, xscale = 1, yscale = 1, rot=0, alpha=1) {
		var child = new __button(sprites, callback, args, left, top, xscale, yscale, rot, alpha);
		add_child(child);
		return child;
	}
	///@func frame(left, top, right, bottom, rotation, alpha)
	static frame = function(left=0, top=0, right=0, bottom=0, rotation=0, alpha=1) {
		var child = new __frame(left, top, right, bottom, rotation, alpha);
		add_child(child);
		return child;
	}
}
function __sprite(sprite, animate, left, top, right, bottom, xscale, yscale, anim_frame, rotation, alpha) : __frame(left, top, right, bottom, rotation, alpha) constructor {
	self.sprite = sprite;
	self.frame = anim_frame;
	self.fspd = sprite_get_speed(sprite)/60;
	self.max_frames = sprite_get_number(sprite);
	self.animate = animate;
	
	self.spr_width = sprite_get_width(sprite);
	self.spr_height = sprite_get_height(sprite);
	self.xscale = xscale;
	self.yscale = yscale;
	
	self.use_scale = true;
	
	static draw = function() {
		if(animate) {
			self.frame = (self.frame + self.fspd) mod self.max_frames;
		}
		draw_sprite_ext(self.sprite, self.frame, self.x, self.y, self.xscale, self.yscale, self.rotation, self.colour, self.alpha);
	}
	static update = function() {

	}
}
function __nineslice(sprite, animate, left, top, right, bottom, anim_frame, rotation, alpha) : __frame(left, top, right, bottom, rotation, alpha) constructor {
	self.sprite = sprite;
	self.frame = anim_frame;
	self.fspd = sprite_get_speed(sprite)/60;
	self.max_frames = sprite_get_number(sprite);
	self.animate = animate;
	
	self.spr_width = sprite_get_width(sprite);
	self.spr_height = sprite_get_height(sprite)
	
	static draw = function() {
		if(animate) {
			self.frame = (self.frame + self.fspd) mod self.max_frames;
		}	
		
		var draw_xscale = self.width / self.spr_width;
		var draw_yscale = self.height / self.spr_height;
		draw_sprite_ext(self.sprite, self.frame, self.x, self.y, draw_xscale, draw_yscale, self.rotation, self.colour, self.alpha);
	}
	static update = function() {

	}
}
function __rectangle(left, top, right, bottom, rotation, colour, alpha) : __frame(left, top, right, bottom, rotation, alpha) constructor {
	self.colour = colour;
	static draw = function() {
		draw_sprite_ext(BLANK_PIXEL, 0, self.x, self.y, self.width, self.height, self.rotation, self.colour, self.alpha);
	}
	static update = function() {}
}
function __text(str, font, left, top, colour, alpha, halign, valign, sep) : __frame(left, top, 0, 0, 1, 1, 0, alpha) constructor {
	self.str = str;
	self.font = font;
	self.halign = halign;
	self.valign = valign;
	self.colour = colour;
	
	draw_set_font(font);
	self.sep = string_height("M") * sep;
		
	static draw = function() {
		//text needs its own update_pos...
		if(self.halign == fa_middle) {
			self.width *= 2;	
		}
		
		draw_set_font(self.font);
		draw_set_halign(self.halign);
		draw_set_valign(self.valign);
		draw_set_color(self.colour);
		draw_text_ext(self.x, self.y, self.str, self.sep, self.width);
	}
	static update = function() {}
}
function __button(sprite, callback, args, left, top, xscale, yscale, rotation, alpha)  : __frame(left, top, 1, 1, rotation, alpha) constructor {
	self.sprite = sprite;
	
	self.callback = callback;
	self.args = args;
	
	//Does the button do anything when we click it?
	self.on_press_type = OnPressType.DoNothing;
	self.on_press_args = undefined;
	
	self.spr_width = sprite_get_width(sprite);
	self.spr_height = sprite_get_height(sprite);
	self.xscale = xscale;
	self.yscale = yscale;
	self.use_scale = true;
	
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
		switch(self.state) {
			case ButtonState.Default:
				index = 0;
				break;
			case ButtonState.Hover:
				self.frame += self.fspd;
				if(self.frame >= self.max_frames-1) {
					self.frame = 1;
				} 
				index = self.frame;
				break;
			case ButtonState.Pressing:
			case ButtonState.Pressed:
				index = self.max_frames - 1;
				break;
		}
		draw_sprite_ext(self.sprite, index, self.x, self.y, self.xscale, self.yscale, self.rotation, self.colour, self.alpha);
	}
	static update = function() {
		switch(self.state) {
			case ButtonState.Default:
				if(mouse_on(INPUT.mouse_x, INPUT.mouse_y, x, y)) {
					self.state = ButtonState.Hover;
					self.frame = 1;
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
				self.frame = 1;
				break;
		}
	}
}
