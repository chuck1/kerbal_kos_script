
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

lock throttle to 1.
		
lock steering to up + R(0,0,180) + R(0,-45,0).

wait until apoapsis > launch_altitude.

print "coast".
print "cooldown".
lock throttle to 0.
wait 5.




