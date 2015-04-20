function util_log {
	parameter line.
	
	log ("T+" + round(missiontime,0) + " " + line) to ("log_" + ship:name + ".txt").
	
}

function util_boot_run {
	parameter boot_run_file.
	
	log " " to "boot.ks".
	delete "boot.ks" from 0.
	
	log (" ")                              to "boot.ks".
	log ("run boot_pre.")                  to "boot.ks".
	log ("run " + boot_run_file + ".")     to "boot.ks".
	log ("run boot_post.")                 to "boot.ks".
	log (" ")                              to "boot.ks".
	
	reboot.
}
function util_boot_func {
	parameter boot_func_name.
	parameter boot_func_args.

	print "util_boot_func".
	
	log " " to "boot.ks".
	delete "boot.ks" from 0.
	
	log (" ")                        to "boot.ks".
	log ("run boot_pre.")            to "boot.ks".
	
	local str is boot_func_name + "(".
	local i is 0.
	until i = boot_func_args:length {
		if i = (boot_func_args:length - 1) {
			set str to str + boot_func_args[i].
		} else {
			set str to str + boot_func_args[i] + ", ".
		}
		set i to i + 1.
	}
	
	log (str + ").")      to "boot.ks".
	
	log ("run boot_post.")                 to "boot.ks".
	log (" ")                              to "boot.ks".
	
	reboot.
}


function util_warp {
	parameter warp_string.
	parameter warp_sub.
	
	print "util_warp".

	declare local warp_eta to 0.
	
	if warp_string = "apo" {
		lock warp_eta to eta:apoapsis - warp_sub.
	} else if warp_string = "per" {
		lock warp_eta to eta:periapsis - warp_sub.
	} else if warp_string = "node" {
		set n to nextnode.
		lock warp_eta to n:eta - warp_sub.
	} else if warp_string = "trans" {
		lock warp_eta to eta:transition - warp_sub.
	} else {
		print "ERROR".
		print neverset.
	}
	
	set warp_limit to 7.
	
	set warp_t to 1.
	
	if ship:body:atm:exists and ship:altitude < ship:body:atm:height {
	} else {
	
		until warp_eta < 1 {
			if warp_eta > 100000 * warp_t and warp_limit > 6 {
				set warp to 7.
			} else if warp_eta > 10000 * warp_t {
				set warp to 6.
			} else if warp_eta > 1000 * warp_t {
				set warp to 5.
			} else if warp_eta > 100 * warp_t {
				set warp to 4.	
			} else if warp_eta > 50 * warp_t {
				set warp to 3.	
			} else if warp_eta > 10 * warp_t {
				set warp to 2.
			} else if warp_eta > (5 * warp_t) {
				set warp to 1.
			}
	
			if 1 {
			clearscreen.
			print "WARP".
			print "===================".
			print "    mode " + warp_string.
			print "    warp " + warp.
			print "    eta  " + warp_eta.
			}
	
			wait 0.1.
		}
	
	}
	
	set warp to 0.
	
	//cleanup
	unlock warp_eta.
	unset warp_eta.
}	

function util_warp_per {
	parameter warp_sub.

	util_warp("per", warp_sub).
	
}
function util_warp_apo {
	parameter warp_sub.

	util_warp("apo", warp_sub).
	
}
function util_warp_trans {
	parameter warp_sub.

	util_warp("trans", warp_sub).
	
}

print "loaded library util".


