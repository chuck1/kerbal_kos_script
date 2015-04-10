set t0 to time.

set wait_orient_ret to 0.

print "wait for reorientation".
until vang(steering:vector, ship:facing:vector) < 0.1 {
	if (time - t0):seconds > 30 {
		set wait_orient_ret to 1.
		break.
	}
}
if wait_orient_ret = 0 {
	print "reorientation complete".
} else {
	print "reorient failure".
	print "possible causes:".
	print "    sas is on".
	print "    ship torque is underpowered".
	print "    steering target is unstable".
}

