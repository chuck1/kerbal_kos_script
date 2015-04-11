
if ship:maxthrust = 0 {
	stage.
}

lock steering to R(up:pitch, up:yaw, ship:facing:roll).

lock throttle to 0.7.

wait 2.

set dir to heading(180,10).
lock steering to R(dir:pitch, dir:yaw, ship:facing:roll).

wait 3.

lock throttle to 0.

wait 2.

run power_land_final.





