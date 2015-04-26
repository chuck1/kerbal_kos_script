function file_compile_and_copy {
	parameter fn.
	switch to 0.
	compile fn.
	copy fn to 1.
	switch to 1.
}
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
function util_boot_filename_arch {
	parameter x.
	return "boot_" + x:rootpart:uid + ".ks".
}
function util_boot_filename {
	parameter x.
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
function util_boot_post {

	local filename is util_boot_filename(ship).

	if boot_return = 0 {
		print "mission accomplished".
		delete filename.
	} else {
		reboot.
	}
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
	log ("util_boot_post().") to filename.
	log (" ")     to filename.
	
	reboot.
}
function util_boot_func {
	parameter boot_func_name.
	parameter boot_func_args.

	print "util_boot_func".

	//local filename is util_boot_filename_arch(ship).
	local filename is util_boot_filename(ship).
	
	log " " to filename.
	delete filename.
	
	local str is "global boot_return is " + boot_func_name + "(" + util_string_join(boot_func_args, ", ") + ").".
	
	log (" ")      to filename.
	log ("run load_libraries.") to filename.
	log (str)      to filename.
	log ("util_boot_post().") to filename.
	log (" ")      to filename.
	
	if 0 { // rename not working	
	// save to archive
	copy filename to 0.

	rename file filename to "boot.ks".
	}

	reboot.
}
