lock throttle to 0.
//lock throttle to 0.01.

// fuel tanks shall be named "stage0", "stage1", and so on
// where stage 0 is the last stage to deplete

// ===========================================
// return lists

set ship_stage_mass_fuel          to list().
set ship_stage_thrust_max         to list().
set ship_stage_fuel_rate_max      to list().
set ship_stage_duration_max       to list().
set ship_stage_deltav             to list().
set ship_stage_engines            to list().
set ship_stage_engines_thrust_max to list().
set ship_stage_engines_isp        to list().

// ===========================================
// general vars

set g0 to kerbin:mu / kerbin:radius^2.

// ===========================================
// determine number of stages
// and populate lists with empty values

set temp_engines_active to list().
set temp_engines_active_isp to list().

set ship_stage_count to 0.
until 0 {
	set tanks to ship:partsdubbed("stage" + ship_stage_count).
	if tanks:length = 0 {
		break.
	}
	
	ship_stage_thrust_max:add(0).
	ship_stage_fuel_rate_max:add(0).
	ship_stage_duration_max:add(0).
	ship_stage_deltav:add(0).
	
	set ship_stage_count to ship_stage_count + 1.
}

// engines[stage][stage_activation][engine_index] = value

// ===========================================
// populate stage engines lists
set i to 0.
until i = 10 { //ship_stage_count {

	ship_stage_engines:add(list()).
	ship_stage_engines_thrust_max:add(list()).
	ship_stage_engines_isp:add(list()).

	// get all engines in this stage
	set i_temp to 0.
	until i_temp = 10 {
		set engines_temp to ship:partsdubbed("stage" + i + "e" + i_temp).
	
		ship_stage_engines[i]:add(engines_temp).
		ship_stage_engines_thrust_max[i]:add(list()).
		ship_stage_engines_isp[i]:add(list()).
		
		for eng in engines_temp {
			if eng:ignition {
				temp_engines_active:add(eng).
				temp_engines_active_isp:add(eng:isp).
				set isp to eng:isp.
				ship_stage_engines_thrust_max[i][i_temp]:add(eng:maxthrust).
			} else {
				eng:activate().
				wait until eng:ignition.
				ship_stage_engines_thrust_max[i][i_temp]:add(eng:maxthrust).
				set isp to eng:isp.
				eng:shutdown().
				wait until not (eng:ignition).
			}
			
			print "    isp " + isp.

			ship_stage_engines_isp[i][i_temp]:add(isp).
		}

		set i_temp to i_temp + 1.
	}
	// prep for next loop
	set i to i + 1.
}

// ===========================================
// calculate current fuel rate

// instantaneous fuel consumption rates
set ship_fuel_rate     to 0.
set ship_fuel_rate_max to 0.


set i to (ship_stage_count - 1).
until i < 0 {

	// calculate
	for engines in ship_stage_engines[i] {
		for eng in engines {
			if eng:ignition {
				set ship_fuel_rate to
					ship_fuel_rate +
					eng:thrust / eng:isp / g0.
				set ship_fuel_rate_max to
					ship_fuel_rate_max +
					eng:maxthrust / eng:isp / g0.
			}
		}
	}

	// prep for next loop
	set i to i - 1.
}



// ===============================================
// calc deltav


// the temp_ship_ variables are the values at
// each stage in the following section

set temp_ship_fuel_rate_max to ship_fuel_rate_max.

// max thrust for all active engines
// used to calc max thrust for future stages by
// subtracting depleted stages
set temp_ship_thrust_max    to ship:maxthrust.



set mass_ship to ship:mass.

set ship_deltav to 0.


set i to (ship_stage_count - 1).
until i < 0 {
	set string to "stage" + i.

	print "stage" + i.

	set tanks        to ship:partsdubbed(string).
	set engines      to list().
	
	// instantaneous
	set stage_mass_fuel  to 0.
	set stage_mass       to 0.
	
	// max thrust of this stage engines only
	// not true max thrust even if this is current stage
	set stage_thrust_max to 0.
	
	// ==========================================
	// thrust and fuel_rate new to this stage
	
	// get all engines to be activated
	// in this stage (that are not already activated)
	set i1 to 0.
	until i1 = ship_stage_count {
		set i2 to 0.
		for eng in ship_stage_engines[i1][i] {
			if not (eng:ignition) {
				
				set isp        to ship_stage_engines_isp[i1][i][i2].
				set thrust_max to ship_stage_engines_thrust_max[i1][i][i2].
	
				temp_engines_active:add(eng).
				temp_engines_active_isp:add(isp).
			
				set temp_ship_thrust_max to
					temp_ship_thrust_max +
					thrust_max.

				set temp_ship_fuel_rate_max to
					temp_ship_fuel_rate_max +
					thrust_max / isp / g0.

			}
			set i2 to i2 + 1.
		}
		set i1 to i1 + 1.
	}

	// ===========================================
	// calc effective isp
	
	set den to 0.

	//print "    active engines".
	set ie to 0.
	until ie = temp_engines_active:length {
		set eng to temp_engines_active[ie].
		set isp to temp_engines_active_isp[ie].

		//print "        " + e.

		set den to den + eng:maxthrust / isp.

		set ie to ie + 1.
	}

	set isp_effective to temp_ship_thrust_max / den.

	// ===========================================
	// calc this stage mass and mass_fuel

	for t in tanks {
		set stage_mass_fuel to
			stage_mass_fuel + (t:mass - t:drymass).
		set stage_mass to
			stage_mass + t:mass.
	}

	set i1 to 0.
	until i1 = ship_stage_engines[i]:length {
	//for engines in ship_stage_engines[i] {
		set engines to ship_stage_engines[i][i1].
		
		set i2 to 0.
		until i2 = engines:length {
		//for e in engines {
			set eng to engines[i2].

			set ve to ship_stage_engines_isp[i][i1][i2] * g0.

			set stage_mass to
				stage_mass + eng:mass.

			set ship_stage_fuel_rate_max[i] to
				ship_stage_fuel_rate_max[i] +
				eng:maxthrust / ve.

			set ship_stage_thrust_max[i] to
				ship_stage_thrust_max[i] +
				eng:maxthrust.

			set i2 to i2 + 1.
		}
		set i1 to i1 + 1.
	}

	set ship_stage_duration_max[i] to
		stage_mass_fuel /
		temp_ship_fuel_rate_max.
	
	set ship_stage_deltav[i] to
		ve * ln(mass_ship / (mass_ship - stage_mass_fuel)).

	set ship_deltav to ship_deltav + ship_stage_deltav[i].
	
	print "ship deltav " + ship_deltav.
	
	// ==========================================
	// prep for next loop
	set i1 to 0.
	until i1 = temp_engines_active:length {
		set removed to false.
		set i2 to 0.
		until i2 = 10 {
			if temp_engines_active[i1]:tag = ("stage" + i + "e" + i2) {
				temp_engines_active:remove(i1).
				temp_engines_active_isp:remove(i1).
				set removed to true.
				break.
			}
			set i2 to i2 + 1.
		}
		if removed {
		} else {
			set i1 to i1 + 1.
		}
	}
	
	
	
	set mass_ship to mass_ship - stage_mass.

	//set temp_ship_fuel_rate to
	//	temp_ship_fuel_rate -
	//	ship_stage_fuel_rate[i].

	set temp_ship_fuel_rate_max to
		temp_ship_fuel_rate_max -
		ship_stage_fuel_rate_max[i].

	set temp_ship_thrust_max to
		temp_ship_thrust_max -
		ship_stage_thrust_max[i].

	set i to i - 1.

}

print "deltav total " + ship_deltav.




