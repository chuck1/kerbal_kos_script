//declare parameter b.

print "WARNING: assumes burning prograde will result in free return".

if not (ship:obt:hasnextpatch) {
	set burn_to_encounter_body  to burn_to_free_return_body.
	set burn_to_encounter_alt to 0.
	run burn_to_encounter.
}

lock steering to prograde.
run wait_orient.

lock throttle to 0.1.

wait until ship:obt:nextpatch:nextpatch:periapsis < ship:body:atm:height * 0.8.

lock throttle to 0.

print "cooldown".
wait 5.

