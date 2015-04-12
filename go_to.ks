// PARAMETER go_to_dest.

set add_line_line to "GO TO DEST".
run add_line.
set lines_indent to lines_indent + 1.

if ship:body = go_to_dest[2] and ship:verticalspeed < 0.01 and alt_radar < 10 {
	// landed on body
} else {

	set transfer_to_moon_target to go_to_dest[2].
	run transfer_to_moon_low.

	set mvr_flyover_gc to go_to_dest[0].
	run mvr_flyover.

}



set get_highest_peak_body to ship:body.
run get_highest_peak.



until 0 {
	
	if go_to_dest[0]:distance < 15000 {
		break.
	}

	set hop_mode to "latlong".
	set hop_dest to mun_arch.
	run hop.
}


set hover_alt_mode to "asl".
set hover_hor_mode to "latlong".
set hover_alt      to mun_arch[1].
set hover_dest     to mun_arch.
run hover.

run power_land_final.

set lines_indent to lines_indent - 1.


