declare parameter go_to_target.
clearscreen.


run lib_util.
run lib_util_ship.
run lib_util_wait.

run global_var.




local args is list().
args:add(go_to_target).

util_boot_func("go_to", args).



