//declare parameter deorbit_body.
//declare parameter deorbit_angle.

print "DEORBIT ----------------------------------".
print "body:       " + deorbit_body.
print "angle:      " + deorbit_angle.
wait 2.

if ship:body:atm:exists {
	run deorbit_atm.
} else {
	run deorbit_no_atm.
}

// reset default
set deorbit_body  to sun.
set deorbit_angle to 120.

