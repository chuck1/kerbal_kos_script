
if ship:maxthrust = 0 {
	stage.
}

print "launch!".
lock throttle to 0.8.
lock steering to up + R(0,0,180).



if legs {
	set legs to false.
}

when stage:liquidfuel < 0.001 then {
    stage.
    preserve.
}

if not (ship:body:atm:exists) {
	print "ERROR no atm".
	print neverset.
}



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

wait until ship:apoapsis > launch_altitude.

print "coast".
lock throttle to 0.
wait 5.




