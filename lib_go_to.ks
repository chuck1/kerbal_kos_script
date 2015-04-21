
function go_to_1 {
	parameter go_to_dest.
	
	until 0 {
		
		if go_to_dest[0]:distance < 15000 {
			break.
		}
	
		set hop_mode to "latlng".
		set hop_dest to go_to_dest.
		run hop.
	}
	
	
	local sa is list(). sa:add("latlng"). sa:add(go_to_dest).
	hover(0, sa).
	
	run power_land_final.
	
	
	util_log("lat error " + (go_to_dest[0]:lat - latitude)).
	util_log("lng error " + (go_to_dest[0]:lng - longitude)).

	return 0.
}
function go_to {
	parameter go_to_dest.
	//local go_to_dest is get_destination(go_to_dest_string).

	print "go_to " + go_to_dest[3].
	
	util_log("go_to " + go_to_dest[3]).
	
	set go_to_complete to false.
	
	set ship:control:pilotmainthrottle to 0.
	
	
	if ship:body = go_to_dest[2] {
	
		local obt_type is calc_obt_type().
		
		if (obt_type = "prelaunch") or (obt_type = "landed") {
	
			go_to_1(go_to_dest).
			
			return 0.
		
		} else if obt_type = "suborbit" {
	
			local alt_low is calc_obt_alt_low(go_to_dest[2]).
			
			local soe_low is calc_obt_soe_circle(go_to_dest[2], alt_low).
			
			if calc_obt_soe(ship) > (soe_low + 50000) {
				//check orbital props to see if on a high speed collision course from transfer
				run circle_low.
			} else {
				//on an appropriate landing course
	
				run go_to_suborbital_approach(go_to_dest).
		
				go_to_1(go_to_dest).
				
				return 0.
			}
	
		} else if (obt_type = "elliptic") {

			circle("low").

		} else if (obt_type = "circular") {
			
			if circle("low") = 0 {
				set mvr_flyover_gc to go_to_dest[0].
				run mvr_flyover.
			}

		} else {
			print "invalid obt type: " + obt_type.
			print neverset.
		}
	
	} else {
		transfer_to(go_to_dest[2], "low").
	}

	return 1.
}


print "loaded library go_to".




