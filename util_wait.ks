
function util_wait_orient {
	
	declare local t0 is time.
	declare local ret is 0.
	
	print "wait for reorientation".
	until vang(steering():vector, ship:facing:vector) < 0.1 {
		if (time - t0):seconds > 30 {
			set ret to 1.
			break.
		}
	}
	if ret = 0 {
		print "reorientation complete".
	} else {
		print "reorient failure".
		print "possible causes:".
		print "    sas is on".
		print "    ship torque is underpowered".
		print "    steering target is unstable".
	}

	return ret.
}

print "loaded library util_wait".

