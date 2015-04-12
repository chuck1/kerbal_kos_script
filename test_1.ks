
if ship:maxthrust = 0 {
	stage.
}

set dir to heading(180,10).
lock steering to R(dir:pitch, dir:yaw, ship:facing:roll).

lock throttle to 0.3.

wait 3.

lock throttle to 1.

wait 3.

lock throttle to 0.

wait 1.

run power_land_final.





