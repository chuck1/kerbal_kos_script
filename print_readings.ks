
run kos_init.

//set t0 to TIME.

lock pres to ship:body:atm:sealevelpressure * ( CONSTANT():E ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ) ).

//until TIME:SECONDS > t0:SECONDS + 10 {
until 0 {
	clearscreen.
	print "time                 " + time.
	print "ship:altitude        " + ship:altitude.
	print "soe                  " + calc_obt_soe(ship).
	print "semimajoraxis        " + ship:obt:semimajoraxis.
	print "semiminoraxis        " + ship:obt:semiminoraxis.
	print "radius               " + ship:body:radius.
	print "soe mun low          " + calc_obt_soe_circle(mun, calc_obt_alt_low(mun)).
	print "soe mun low          " + calc_obt_soe_circle(mun, 2 * calc_obt_alt_low(mun)).
	
	//print "E                    " + CONSTANT():E.	
	//print "atm:sealevelpressure " + ship:body:atm:sealevelpressure.
	//print "atm:scale            " + ship:body:atm:scale.
	//print "exp                  " + -1 * ship:altitude / ship:body:atm:scale.
	//print "                     " + CONSTANT():E ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ).
	//print "pressure             " + pres.
	wait 0.001.
}


