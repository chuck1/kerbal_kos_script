function util_log {
	parameter line.
	
	log ("T+" + round(missiontime,0) + " " + line) to ("log_" + ship:name + ".txt").
	
	return.
}

function util_boot_run {
	parameter boot_run_file.
	
	log " " to "boot.ks".
	delete "boot.ks" from 0.
	
	log ("wait 5.")                        to "boot.ks".
	log ("run boot_pre.")                  to "boot.ks".
	log ("run " + boot_run_file + ".")     to "boot.ks".
	log ("run boot_post.")                 to "boot.ks".
	log (" ")                              to "boot.ks".
	
	reboot.
}


print "loaded library util".

