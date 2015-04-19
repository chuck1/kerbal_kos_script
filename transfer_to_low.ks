// declare parameter transfer_to_target

util_log("transfer_to_low " + transfer_to_target).

print "transfer_to_target " + transfer_to_target.

if transfer_to_target = sun {
	print "cannot transfer to sun".
	print neverset.
} else if transfer_to_target:obt:body = sun {
	set transfer_to_planet_target to transfer_to_target.
	run transfer_to_planet_low.
} else if transfer_to_target:obt:body:obt:body = sun {
	run transfer_to_moon_low(transfer_to_target).
}

// cleanup

unset transfer_to_target.



