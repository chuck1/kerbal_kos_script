declare parameter go_to_target.

run load_libraries.

local args is list().
args:add(go_to_target).

util_boot_func("go_to", args).



