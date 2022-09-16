
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
function print() {
	var str = "";
	for(var i = 0; i < argument_count; i++) {
		str += string(argument[i]) + ", ";	
	}
	show_debug_message(str);
}


