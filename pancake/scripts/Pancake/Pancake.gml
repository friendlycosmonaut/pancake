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
	static draw = function() {
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var child = stack[i];
			if(child.visible) {
				//x, y, xscale, yscale, rotation, colour, alpha
				child.draw_event(0, 0, 1, 1, 0, c_white, 1);
			}
		}
	}
	static update = function() {
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var child = stack[i];
			if(child.active) {
				child.update();
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
		width *= gui_width;
		height *= gui_height;
		var new_frame = new __frame(0, 0, width, height, rotation, alpha);
		array_push(stack, new_frame);
		return new_frame;
	}
	
	initialise();
}

function __frame(x, y, width, height, rotation, alpha) constructor {
	active = true;
	visible = true;
	stack = [];
	
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
	static draw_event = function(x, y, xscale, yscale, rotation, alpha) {
		self.x = relative.x + x;
		self.y = relative.y + y;
		self.rotation = relative.rotation * rotation;
		self.alpha = relative.alpha * alpha;
		self.xscale = relative.xscale * xscale;
		self.yscale = relative.xscale * yscale;
		
		draw();
		draw_children(self.x, self.y, self.xscale, self.yscale, self.rotation, self.alpha);
	}
	
	static draw = function() {}
	static draw_children = function(x, y, xscale, yscale, rotation, alpha) {
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			var element = stack[i];
			element.draw_event(x, y, xscale, yscale, rotation, alpha);
		}	
	}
		
	static update = function() {
		var c = array_length(stack);
		for(var i = 0; i < c; i++) {
			stack[i].update(self.x, self.y);
		}	
	}
	
	//Functions
	static mouse_on = function(mouse_x, mouse_y, x, y) {
		return point_in_rectangle(mouse_x, mouse_y, x, y, x+self.width, y+self.height);
	}
	
	//Widgets
	static sprite = function(spr, animate=false, x=0, y=0, frame=0, rotation=0, colour=c_white, alpha=1) {
		x *= self.width;
		y *= self.height;
		var rect = new __sprite(spr, animate, x, y, frame, rotation, colour, alpha);
		array_push(stack, rect);
		return rect;
	}
	static rectangle = function(x=0, y=0, width=1, height=1, colour=c_white, rotation=0, alpha=1) {
		width *= self.width;
		height *= self.height;
		x *= self.width;
		y *= self.height;
		var rect = new __rectangle(x, y, width, height, rotation, colour, alpha);
		array_push(stack, rect);
		return rect;
	}
	static text = function(str, font, x=0, y=0, width=1, height=1, colour=c_white, alpha, halign=fa_left, valign=fa_top, sep=1) {
		width *= self.width;
		height *= self.height;
		x *= self.width;
		y *= self.height;
		var txt = new __text(str, font, x, y, width, height, colour, alpha, halign, valign, sep);
		array_push(stack, txt);
		return txt;
	}
	static button = function(sprites, callback, args=[], x=0, y=0, rot=0, colour=c_white, alpha=1) {
		x *= self.width;
		y *= self.height;
		var rect = new __button(sprites, callback, args, x, y, rot, colour, alpha);
		array_push(stack, rect);
		return rect;
	}
	static frame = function(x=0, y=0, width=1, height=1, rotation=0, alpha=1) {
		width *= self.width;
		height *= self.height;
		x *= self.width;
		y *= self.height;
		var new_frame = new __frame(x, y, width, height, rotation, alpha);
		array_push(stack, new_frame);
		return new_frame;
	}
}
function __sprite(spr, animate, x, y, anim_frame, rotation, colour, alpha) : __frame(x, y, 1, 1, rotation, alpha) constructor {
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
		
		draw_sprite_ext(spr, frame, x, y, xscale, yscale, rotation, colour, alpha);
	}
	static update = function(x, y) {
		x += self.x;
		y += self.y;
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
function __button(sprites, callback, args, x, y, rotation, colour, alpha)  : __frame(x, y, 1, 1, rotation, alpha) constructor {
	self.sprites = is_array(sprites) ? sprites : [sprites];
	self.fspds = [];
	self.max_frames = [];
	self.frame = 0;
	for(var i = 0; i < array_length(self.sprites); i++) {
		var spr = self.sprites[i];
		array_push(self.fspds, sprite_get_speed(spr)/60);
		array_push(self.max_frames, sprite_get_number(spr));
	}
	
	self.callback = callback;
	self.args = args;
	self.colour = colour;
	
	//Does the button do anything when we click it?
	self.on_press_type = OnPressType.DoNothing;
	self.on_press_args = undefined;
	
	self.width = sprite_get_width(spr);
	self.height = sprite_get_height(spr);
	self.state = ButtonState.Default;
	
	static set_on_press_type = function(type, args) {
		self.on_press_type = type;
		self.on_press_args = args;
	}
	static draw = function() {
		frame += self.fspds[state];
		if(frame >= max_frames[state]) {
			frame = 0;	
		}
		draw_sprite_ext(sprites[state], frame, x, y, xscale, yscale, rotation, colour, alpha);
	}
	static update = function() {
		switch(state) {
			case ButtonState.Default:
				if(mouse_on(INPUT.mouse_x, INPUT.mouse_y, x, y)) {
					self.state = ButtonState.Hover;
					frame = 0;
				}
				break;
			case ButtonState.Hover:
				if(!mouse_on(INPUT.mouse_x, INPUT.mouse_y, x, y)) {
					self.state = ButtonState.Default;
					frame = 0;
				} else if(INPUT.mouse_left_r) {
					self.state = ButtonState.Pressed;
					frame = 0;
					if(self.callback != undefined) {
						function_execute_alt(self.callback, self.args);
					}	
				}
				break;
			case ButtonState.Pressed:
				if(frame + self.fspds[state] >= max_frames[state]) {
					self.state = ButtonState.Default;
					frame = 0;
				}
				break;
		}
	}
}

function function_execute_alt(func, args) {
	var f = func;
	var a = args == undefined ? [] : args;
	switch(array_length(args)) {
		case 0: return f(); 	
		case 1: return f(a[0]);
		case 2: return f(a[0], a[1]);
		case 3: return f(a[0], a[1], a[2]);
		case 4: return f(a[0], a[1], a[2], a[3]);
		case 5: return f(a[0], a[1], a[2], a[3], a[4]);
		case 6: return f(a[0], a[1], a[2], a[3], a[4], a[5]);
	}
}