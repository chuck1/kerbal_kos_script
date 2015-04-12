
//set t0 to TIME.

lock pres to ship:body:atm:sealevelpressure * ( CONSTANT():E ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ) ).

//until TIME:SECONDS > t0:SECONDS + 10 {
until 0 {
	clearscreen.
	print "time                 " + time.
	print "ship:altitude        " + ship:altitude.
	print "E                    " + CONSTANT():E.	
	print "atm:sealevelpressure " + ship:body:atm:sealevelpressure.
	print "radius               " + ship:body:radius.
	print "atm:scale            " + ship:body:atm:scale.
	print "exp                  " + -1 * ship:altitude / ship:body:atm:scale.
	print "                     " + CONSTANT():E ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ).
	print "pressure             " + pres.
	wait 0.1.
}
