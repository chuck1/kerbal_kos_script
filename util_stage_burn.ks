
list engines in util_stage_burn_el.

for engine in util_stage_burn_el {
	if engine:flameout {
		stage.
		break.
	}
}

until not (ship:maxthrust = 0) {
	stage.
	wait 0.5.
}

