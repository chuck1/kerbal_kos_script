// PARAMETER go_to_dest.

util_log("go_to " + go_to_dest[3]).

set go_to_complete to false.

set ship:control:pilotmainthrottle to 0.


if ship:body = go_to_dest[2] {

	run calc_classify_obt.
	
	if (orbit_type = "prelaunch") or (orbit_type = "landed") {
	
		until 0 {
			
			if go_to_dest[0]:distance < 15000 {
				break.
			}
		
			set hop_mode to "latlng".
			set hop_dest to go_to_dest.
			run hop.
		}
		
		
		set hover_vert_mode to "asl".
		set hover_hor_mode  to "latlng".
		set hover_alt       to go_to_dest[1].
		set hover_dest      to go_to_dest.
		run hover.
		
		run power_land_final.
		
		
		util_log("lat error " + (go_to_dest[0]:lat - latitude)).
		util_log("lng error " + (go_to_dest[0]:lng - longitude)).
		
		set go_to_complete to true.
	
	} else if orbit_type = "suborbit" {

		run go_to_suborbital_approach(go_to_dest).


		until 0 {
			
			if go_to_dest[0]:distance < 15000 {
				break.
			}
		
			set hop_mode to "latlng".
			set hop_dest to go_to_dest.
			run hop.
		}
		
		
		set hover_vert_mode to "asl".
		set hover_hor_mode  to "latlng".
		set hover_alt       to go_to_dest[1].
		set hover_dest      to go_to_dest.
		run hover.
		
		run power_land_final.
		
		
		print "lat error " + (go_to_dest[0]:lat - latitude).
		print "lng error " + (go_to_dest[0]:lng - longitude).
		
		set go_to_complete to true.


	} else if (orbit_type = "elliptic") {
		run circle_low.
	} else if (orbit_type = "circular") {
		
		run circle_low.

		if circle_ret = 0 {
			set mvr_flyover_gc to go_to_dest[0].
			run mvr_flyover.
		}
	} else {
		print "invalid obt type: " + orbit_type.
		print neverset.
	}

} else {
	set transfer_to_target to go_to_dest[2].
	run transfer_to_low.
}





// cleanup
set lines_indent to lines_indent - 1.
unset go_to_dest.






