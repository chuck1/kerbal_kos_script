// declare parameter transfer_to_target

if transfer_to_target = sun {
} else if transfer_to_target:obt:body = sun {
	set transfer_to_planet_target to transfer_to_target.
	run transfer_to_planet.
} else if transfer_to_target:obt:body:obt:body = sun {
	set transfer_to_moon_target to transfer_to_target.
	run transfer_to_moon.
}



