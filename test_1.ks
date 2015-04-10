
if ship:maxthrust = 0 {
	stage.
}

lock steering to R(up:pitch, up:yaw, ship:facing:roll).

lock throttle to 1.

wait 3.

set dir to heading(180, 10).
lock steering to R(dir:pitch, dir:yaw, ship:facing:roll).

wait 1.

lock throttle to 1.

wait 4.

lock throttle to 0.

set power_land_final_mode_hori to "retro".
run power_land_final.





