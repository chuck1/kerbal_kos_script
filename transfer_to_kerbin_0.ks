
run kos_init.

set transfer_to_target to kerbin.
run transfer_to.

run calc_classify_obt.

if (orbit_type = "circular") and (ship:body = kerbin) {
	set mission_complete to true.
}

