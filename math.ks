
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

function math_clamp_angle {
	parameter a.
	
	if a < 0 {
		return a + 360.
	} else if a > 360 {
		return a - 360.
	}

	return a.
}

print "loaded library math".

