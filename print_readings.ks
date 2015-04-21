declare parameter x.

run kos_init.

//set t0 to TIME.

lock pres to ship:body:atm:sealevelpressure * ( CONSTANT():E ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ) ).

//until TIME:SECONDS > t0:SECONDS + 10 {
until 0 {
	clearscreen.
	print "time                 " + time.
	print "apoapsis             " + x:apoapsis.
	print "periapsis            " + x:periapsis.
	print "periapsis            " + (-x:obt:semimajoraxis * (x:obt:eccentricity - 1) - x:body:radius).
	print "eccentricity         " + x:obt:eccentricity.
	print "ship:altitude        " + x:altitude.
	print "soe                  " + calc_obt_soe(x).
	print "semimajoraxis        " + x:obt:semimajoraxis.
	print "semiminoraxis        " + x:obt:semiminoraxis.
	print "true anomaly         " + x:obt:trueanomaly.
	print "ecc  anomaly         " + calc_obt_eccentric_anomaly(x).
	print "mean anomaly         " + calc_obt_mean_anomaly(x).
	print "eta apo              " + sprint_clock(calc_obt_time_to_apoapsis(x)).
	print "eta per              " + sprint_clock(calc_obt_time_to_periapsis(x)).
	print "body radius          " + x:body:radius.
	print "period               " + x:obt:period.
	print "mean motion          " + calc_obt_mean_motion(x).
	print "mean motion          " + 360 / x:obt:period.
	//print "mean motion          " + sqrt(x:body:mu / x:obt:semimajoraxis).
	
	
	//print "soe mun low          " + calc_obt_soe_circle(mun, calc_obt_alt_low(mun)).
	//print "soe mun low          " + calc_obt_soe_circle(mun, 2 * calc_obt_alt_low(mun)).
	print "speed vert           " + x:verticalspeed.
	print "speed surf           " + x:surfacespeed.
	//print "obt type             " + calc_obt_type().
	
	//print "E                    " + CONSTANT():E.	
	//print "atm:sealevelpressure " + ship:body:atm:sealevelpressure.
	//print "atm:scale            " + ship:body:atm:scale.
	//print "exp                  " + -1 * ship:altitude / ship:body:atm:scale.
	//print "                     " + CONSTANT():E ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ).
	//print "pressure             " + pres.
	wait 0.1.
}


