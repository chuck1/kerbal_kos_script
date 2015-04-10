declare parameter v.

//positionat(orbitable,time).


set t to time.
set t_start to t.

lock pos to positionat(ship, t) - positionat(kerbin, t).

lock a to vang(v, pos).

set P to ship:obt:period.
set dt to P / 10.

// find a local min at a positive time
// a---dt---a0--dt--a1
until 0 {
	set a0 to a.
	set t to t + dt.
	set a1 to a.
	set t to t + dt.
	set a2 to a.
	
	//print "t  " + (t - t_start).
	//print "a0 " + a0.
	//print "a1 " + a1.
	//print "a2 " + a2.

	set t to t - 2 * dt.
	
	if a1 < a0 and a1 < a2 {
		break.
	}

	set t to t + dt.
}

until 0 {
	set t to t - dt.
	set a0 to a.
	set t to t + 2 * dt.
	set a1 to a.
	set t to t - dt.
	
	if a0 < a {
		set t to t - dt.
	} else if a1 < a { 
		set t to t + dt.
	} else { // a is the best
		set dt to dt * 0.51.
		if dt < 0.5 {
			break.
		}
	}
}

//print "time = " + t.
//print "eta  = " + (time:seconds - t).
