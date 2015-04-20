
run kos_init.

if ship:body:atm:exists {
	run power_land_atm.
} else {
	run power_land_no_atm.
}

