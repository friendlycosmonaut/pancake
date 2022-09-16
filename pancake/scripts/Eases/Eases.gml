function ease_in_out_back(val) {
	var c1 = 1.70158;
	var c2 = c1 * 1.525;

	return val < 0.5
	  ? (power(2 * val, 2) * ((c2 + 1) * 2 * val - c2)) / 2
	  : (power(2 * val - 2, 2) * ((c2 + 1) * (val * 2 - 2) + c2) + 2) / 2;
}

function ease_out_expo(val) {
	return val == 1 
		? 1 
		: 1 - power(2, -10 * val);
}