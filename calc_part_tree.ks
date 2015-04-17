
list parts in part_tree_list.

set indent to "".

set count to 0.
set radial_count to 0.

set in_segment to false.

set radial_count_set to false.

for part in part_tree_list {

	if radial_count_set {
	
		if count = count_radial {

			set count to 0.
		
			set in_segment to false.
	
			set indent to "".
		}

		if part:name = "radialDecoupler2" {
			print part:name.
			set indent to "    ".
		} else {
			print indent + part:name.
		}


		
		if in_segment {
			set count to count + 1.
		}

	} else {

		if part:name = "radialDecoupler2" {

			if count > 0 {
				print "count = " + count.
				set count_radial to count.
				set radial_count_set to true.
				set count to 0.
			}
		
			set in_segment to true.
		
			print part:name.
		
			set indent to "    ".
		} else {
			print indent + part:name.
		
			if in_segment {
				set count to count + 1.
			}
		}
	}
	wait 0.2.
}





