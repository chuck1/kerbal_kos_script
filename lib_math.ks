
function math_sign {
	parameter x.
	if x < 0 {
		return -1.
	} else {
		return 1.
	}
}

function math_ship_h {
//	return 
}
function math_clamp {
	parameter x.
	parameter a.
	parameter b.
	return max(a, min(b, x)).
}
function math_clamp_angle {
	parameter a.
	
	if a < 0 {
		return a + 360.
	} else if a > 360 {
		return a - 360.
	}

	return a.
}

function math_deg_to_rad {
	parameter x.
	return x / 180 * constant():pi.
}
function math_rad_to_deg {
	parameter x.
	return x * 180 / constant():pi.
}
function math_arccosh {
	parameter x.

	if x < 1 {
		print neverset.
	}
	
	local y is ln(x + sqrt(x^2 - 1)).

	return math_rad_to_deg(y).
}
function math_arccosh2 {
	parameter x.
	parameter y.
	
	return math_arccosh(x/y).
}
function math_sinh {
	parameter x.

	set x to math_deg_to_rad(x).
	
	local y is (constant():e^x - constant():e^(-x)) / 2.
	
	return y.
}

print "loaded library math".



