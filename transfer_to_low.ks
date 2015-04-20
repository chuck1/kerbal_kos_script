function transfer_to_low {
	declare parameter b.
	
	util_log("transfer_to_low " + b).
	
	print "transfer_to_target " + b.
	
	if transfer_to_target = sun {
		print "cannot transfer to sun".
		print neverset.
	} else if transfer_to_target:obt:body = sun {
		run transfer_to_planet_low(b).
	} else if transfer_to_target:obt:body:obt:body = sun {
		run transfer_to_moon_low(b).
	}
	
}


