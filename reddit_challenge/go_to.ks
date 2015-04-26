declare parameter go_to_target.
clearscreen.



//run lib_hover.
//run lib_calc_ship.

//run lib_get.
run lib_util.
run lib_util_ship.
run lib_util_wait.
//run lib_print.
//run lib_math.
//run lib_calculate.
//run lib_calc_obt.
//run lib_go_to.
//run lib_launch.
//run lib_circle.
//run lib_mvr.
//run lib_transfer.
//run lib_rendez.
//run lib_land.
//run lib_wait.
//run lib_warp.

run global_var.





local args is list().
args:add(go_to_target).

util_boot_func("go_to", args).



