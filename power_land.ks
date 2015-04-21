
run load_libraries.

if ship:body:atm:exists {
	power_land_atm().
} else {
	power_land_no_atm().
}

