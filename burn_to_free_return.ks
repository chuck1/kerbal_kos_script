//declare parameter burn_to_free_return_target

print "WARNING: assumes burning prograde will result in free return".

if not (ship:obt:hasnextpatch) {
	set burn_to_encounter_body  to burn_to_free_return_target.
	set burn_to_encounter_alt to 0.
	run burn_to_encounter.
}

lock steering to prograde.
run wait_orient.



set peri_min to 10000000000000000.

until 0 {
	lock throttle to 0.1.

	if ship:obt:nextpatch:nextpatch:periapsis < ship:body:atm:height * 0.8 {
		break.
	}

	if ship:obt:nextpatch:nextpatch:periapsis > peri_min {
		break.
	}

	set peri_min to min(peri_min, ship:obt:nextpatch:nextpatch:periapsis).
}

lock throttle to 0.

print "cooldown".
wait 5.




unset burn_to_free_return_target.

