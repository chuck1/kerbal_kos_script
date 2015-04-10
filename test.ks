
run global_var.

if alt:radar < 10 {
	lock throttle to 1.
	lock steering to R(up:pitch, up:yaw, ship:facing:roll).
	wait 0.5.
}

set hover_alt_mode to "asl".
set hover_hor_mode to "latlong".

set hover_alt  to 5100.

// top to mun arch
set hover_lat  to mun_arch_lat.
set hover_long to mun_arch_long.

// top of VAB
//set hover_lat  to   -0.097.
//set hover_long to  -74.6189.

run hover.

set hover_alt  to 4890.

run hover.

run power_land_final.



