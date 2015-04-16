
run calc_classify_obt.

if orbit_type = "prelaunch" {

	print "clear log file".

	set boot_run_log_file to (ship:name + "_log.txt").

	log " " to boot_run_log_file.
	delete boot_run_log_file from 0.

}

