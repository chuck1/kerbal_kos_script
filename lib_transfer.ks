
function transfer_to {
	parameter transfer_to_target.
	parameter is_boot_func.

	print "transfer_to".

	if transfer_to_target = sun {
		print neverset.
	} else if transfer_to_target:obt:body = sun {
		run transfer_to_planet(transfer_to_target).
	} else if transfer_to_target:obt:body:obt:body = sun {
		run transfer_to_moon(transfer_to_target).
	}

	if is_boot_func {
		if (calc_obt_type() = "circular") and (ship:body = transfer_to_target) {
			set mission_complete to true.
		}
	}
}


