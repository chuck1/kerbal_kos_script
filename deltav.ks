//declare parameter deltav_alt.
//declare parameter deltav_alt1.
//declare parameter deltav_alt2.

set debug to 0.

// alt is the burn altitude / common altitude

// orbit radius
set deltav_r  to deltav_alt  + ship:body:radius.
set deltav_r1 to deltav_alt1 + ship:body:radius.
set deltav_r2 to deltav_alt2 + ship:body:radius.

// semi-major
set deltav_a1 to (deltav_r + deltav_r1) / 2.
set deltav_a2 to (deltav_r + deltav_r2) / 2.

if debug {
//print "calculate dv".
//print "alt  " + deltav_alt.
//print "alt1 " + deltav_alt1.
//print "alt2 " + deltav_alt2.
//print "r    " + deltav_r.
//print "r1   " + deltav_r1.
//print "r2   " + deltav_r2.
//print "a1   " + deltav_a1.
//print "a2   " + deltav_a2.
}

set dv to sqrt(ship:body:mu * (2/deltav_r - 1/deltav_a2))
	- sqrt(ship:body:mu * (2/deltav_r - 1/deltav_a1)).

unset deltav_alt.
unset deltav_alt1.
unset deltav_alt2.



