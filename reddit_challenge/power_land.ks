run copy_files.

run lib_get.ks.
run lib_obt.ks.
run lib_print.ks.
run lib_math.ks.
run lib_calculate.ks.
run lib_calc_ship.ks.
run lib_calc_obt.ks.
run lib_land.ks.
run lib_util.ks.
run lib_util_ship.ks.
run lib_ves.ks.


if ship:body:atm:exists {
	power_land_atm().
} else {
	power_land_no_atm().
}

