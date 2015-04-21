function util_file_exists {
	parameter filename.
	
	list files in fl.
	for f in fl {
		if f = filename {
			return true.
		}
	}
	return false.
}
function util_file_delete {
	// only works on current archive
	parameter filename.
	if util_file_exists(filename) {
		delete filename.
	}
}
function util_boot_filename {
	parameter x.
	//return "boot_" + x:rootpart:uid + ".ks".
	return "boot.ks".
}
function util_log_filename {
	return "log_" + ship:rootpart:uid + ".txt".
}
function util_log_delete {
	parameter x.
	util_file_delete(util_log_filename).
}
function util_log {
	parameter line.
	log ("T+" + round(missiontime,0) + " " + line) to util_log_filename().
}
function util_string_join {
	parameter string_list.
	parameter string_joiner.

	local str is "".
	local i is 0.

	until i = string_list:length {
		if i = (string_list:length - 1) {
			set str to str + string_list[i].
		} else {
			set str to str + string_list[i] + string_joiner.
		}
		set i to i + 1.
	}
	return str.
}
function util_boot_run {
	parameter boot_run_file.

	local filename is util_boot_filename(ship).
	
	log " " to filename.
	delete filename.

	local str is ("run " + boot_run_file + "(" + util_string_join(boo_func_args, ", ") + ").").

	log (" ")     to filename.
	log ("run load_libraries.") to filename.
	log (str)     to filename.
	log (" ")     to filename.
	
	reboot.
}
function util_boot_func {
	parameter boot_func_name.
	parameter boot_func_args.

	print "util_boot_func".

	local filename is util_boot_filename(ship).
	
	log " " to filename.
	delete filename.
	
	local str is "global boot_return is " + boot_func_name + "(" + util_string_join(boot_func_args, ", ") + ").".
	
	log (" ")      to filename.
	log ("run load_libraries.") to filename.
	log (str)      to filename.
	log (" ")      to filename.
	
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


