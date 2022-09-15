
pancake = new Pancake();
var frame = pancake.frame(0, 0);

var rect = frame.rectangle(0.2, 0.2, 0.6, 0.6, c_gray);
var spr = frame.sprite(spr_bean, false, 0.02, 0.3);

var str = "test test test test testing helo test testest testtes testes testestes";
//str, font, x, y, width, height, colour, alpha, halign, valign, sep
frame.text(str, fnt_text, 0.2, 0.2, 0.3, 0.3);

//spr, callback, args, x, y, rotation, colour, alpha
var but = frame.button([spr_button_default, spr_button_hover, spr_button_pressed], function(spr) {
	spr.animate = !spr.animate;
}, [spr], 0.1, 0.1);

but.text("toggle the bean boogie!!", fnt_text, 0.5, 0.5, 1, 1, c_black, 1, fa_middle, fa_center);