
print "load_libraries".


run lib_get.
run lib_util.
run lib_util_ship.
run lib_util_wait.
run lib_print.
run lib_math.
run lib_calculate.
run lib_calc_ship.
run lib_calc_obt.
run lib_go_to.
run lib_hover.
run lib_launch.
run lib_circle.
run lib_mvr.
run lib_transfer.
run lib_rendez.

run global_var.

if calc_obt_type(ship) = "prelaunch" {
	print "clear log file".
	util_log_delete().
}


copy "go_to" from 0.



