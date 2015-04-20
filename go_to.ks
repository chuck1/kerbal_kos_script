declare parameter go_to_target.

run kos_init.

local args is list().
args:add(go_to_target).
args:add(true).

util_boot_func("go_to", args).



