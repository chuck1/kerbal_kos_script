declare parameter transfer_to_target.

run kos_init.

local args is list().
args:add(transfer_to_target).
args:add(true).

util_boot_func("transfer_to", args).



