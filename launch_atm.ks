declare parameter r.

print "launch!".
lock throttle to 0.8.
lock steering to up + R(0,0,180).
stage.
if legs {
	set legs to false.
}

when stage:liquidfuel < 0.001 then {
    stage.
    preserve.
}

if ship:body:atm:exists {
	lock P to ship:termvelocity - ship:verticalspeed.
	set th to 0.
	lock throttle to th.
	
	set kd to 0.01.

	lock pres to ship:body:atm:sealevelpressure * ( constant():e ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ) ).
	
	until pres < 0.12 {
		set th to P * kd.
		wait 0.1.
	}
	
	print "gravity turn".
	lock throttle to 1.
	lock steering to up + R(0,0,180) + R(0,-45,0).
	
	wait until ship:apoapsis > r.

	print "coast".
	lock throttle to 0.
	wait 5.
}

run circle(r).


