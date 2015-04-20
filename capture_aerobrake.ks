
set capture_aerobrake_ret to 0.

if not (ship:body:atm:exists) {
	print "body has no atm".
	print neverset.
}

if ship:verticalspeed > 0 and altitude > ship:body:atm:height {
	print "heading away from atm".
} else if periapsis > ship:body:atm:height {
	print "periapsis is above atm, do regular capture".
} else {


	run warp_to_atm.

	// 0 captured
	// 1 too deep, 

	

	lock steering to prograde.

	until 0 {
		clearscreen.
		print "CAPTURE AEROBRAKE".
		print "=================".
		print "    vs " + ship:verticalspeed.
	

		if apoapsis < 0 {
		
		} else {
			if apoapsis < ship:body:atm:height {
				print "WARNING: aerobraking was too deep".
				print "begin emergency landing sequence".
				set capture_aerobrake_ret to 1.
				wait 5.
				break.
			}
		}

		if altitude > ship:body:atm:height {
			print "you have left the atm".
			break.
		}

	}

}


if capture_aerobrake_ret = 0 {
	// now perform regular capture program
	run capture(0).
}




