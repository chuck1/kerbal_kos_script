// PARAM transfer_to_moon_target

if ship:body = transfer_to_moon_target {
} else {

	if not (transfer_to_moon_target:obt:body = ship:body) {
	
		set transfer_ip_target to transfer_to_moon_target:obt:body.
		run transfer_ip.

	}

	run launch.

	set match_inc_target to transfer_to_moon_target.
	run match_inc.

	set burn_to_free_return_target to transfer_to_moon_target.
	run burn_to_free_return.

	set warp_string to "trans".
	set warp_sub to 0.
	run warp.
	wait 2.

}

run power_land.


