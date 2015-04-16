// PARAMETER launch_altitude

set lines_add_line to "LAUNCH " + ship:body.
run lines_add.
set lines_indent to lines_indent + 1.


set warp to 0.
sas off.
rcs off.

set get_stable_orbits_body to ship:body.
run get_stable_orbits.



if launch_altitude = 0 {
	set launch_altitude to ship:body:radius / 5.
}

if periapsis > get_stable_orbits_ret[0][0] {
	print "already in orbit".
} else {
	if ship:body:atm:exists {
		run launch_atm.
	} else {
		run launch_no_atm.
	}
}

if 0 { // removed to implement boot_run
if apoapsis > launch_altitude {
	set circle_altitude to apoapsis.
	run circle.
} else {
	set circle_altitude to launch_altitude.
	run circle.
}
}

// cleanup
set lines_indent to lines_indent + 1.
unset launch_altitude.

