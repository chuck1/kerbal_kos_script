
copy "copy_files" from 0.
run copy_files.

run load_libraries.


if calc_obt_type(ship) = "prelaunch" {
	print "clear log file".
	util_log_delete().
}


copy "go_to" from 0.



