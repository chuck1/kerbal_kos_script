//declare parameter deorbit_body.
//declare parameter deorbit_angle.

print "DEORBIT ----------------------------------".
print "body:       " + deorbit_body.
print "angle:      " + deorbit_angle.

if ship:body:atm:exists {
	run deorbit_atm.
} else {
	run deorbit_no_atm.
}



