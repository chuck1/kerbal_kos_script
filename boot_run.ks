declare parameter boot_run_file.


log " " to "boot.ks".
delete "boot.ks" from 0.


log ("wait 5.")                        to "boot.ks".
log ("run boot_pre.")                  to "boot.ks".
log ("run " + boot_run_file + ".")     to "boot.ks".
log (" ")                              to "boot.ks".

reboot.

