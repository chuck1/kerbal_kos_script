
set menu to 0.
set flag_exit to 0.

on ag1 {
	if menu = 0 {
		set flag_exit to 1.
	}
}

until 0 {
	
	clearscreen.
	print "INTERACTIVE".
	print "========================".
	print "patch 0".
	print "    body          " + ship:body.	
	print "    apoapsis      " + round(apoapsis,0).
	print "    periapsis     " + round(periapsis,0).
	print "    eta:apoapsis  " + round(eta:apoapsis,1).
	print "    eta:periapsis " + round(eta:periapsis,1).
	if menu = 0 {
		print "menu".
		print "1: exit".
	}
	
	if flag_exit = 1 {
		break.
	}

	wait 0.1.
}


