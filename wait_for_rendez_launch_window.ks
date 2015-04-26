
function wait_for_rendez_launch_window {
	until 0 {
		//print target:obt:nextpatch:argumentofperiapsis.

		local os1 is obt_struc_current_for(ship).
		local os2 is obt_struc_from_obt(obt_at_body(target, ship:body)).

		local nv is obt_node_vec(os1, os2).
	
		local target_lan is target:obt:nextpatch:lan.
		
		local body_ta is ship:body:obt:trueanomaly.
	
		local ph0 math_clamp_angle(body_ta - target_lan).
		
		local ph is ves_phase_with(ship, sun).
		
	
		clearscreen.
		print "wait for rendez launch window".
		print ph0.
		print ph.
	
		if abs(ph0 - ph) < 0.1 {
			break.
		}
	
		wait 0.01.
	}
}



