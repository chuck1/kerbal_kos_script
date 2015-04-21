declare parameter alt.

run kos_init.

local args is list().
args:add(alt).
args:add(true).

util_boot_func("circle", args).



