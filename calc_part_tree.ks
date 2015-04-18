
list parts in part_tree_list.

set indent to "".

set count to 0.
set radial_count to 0.

set in_segment to false.

set radial_count_set to false.

set indent to "".

set i to 0.
until i = part_tree_list:length {
	if part_tree_list[i]:name = "radialDecoupler2" {
		until 0 {
			if part_tree_list[i]:name = "radialDecoupler2" {
				if not radial_count_set {
					if not (count = 0) {
						set radial_count to count.
						set radial_count_set to true.
					}
				}
				set count to 0.
				//print indent + part_tree_list[i]:name.
			} else if radial_count_set and (count = radial_count) {
				//print indent + "    " + count + " " + part_tree_list[i]:stage + " " + part_tree_list[i]:name.
				set count to 0.
				if ((i + 1) = part_tree_list:length) {
					set i to i + 1.
					break.
				}
				if not (part_tree_list[i+1]:name = "radialDecoupler2") {
					set i to i + 1.
					break.
				}
			} else {
				//print indent + "    " + count + " " + part_tree_list[i]:stage + " " + part_tree_list[i]:name.
				// count parts under radial decoupler
				set count to count + 1.
			}

			set i to i + 1.
		}
	} else {

		//print indent + part_tree_list[i]:stage + " " + part_tree_list[i]:name.

		if part_tree_list[i]:name = "stackDecoupler" {
			set indent to indent + "    ".
		}
		
		set i to i + 1.
	}


	//wait 0.2.
}






set stages to list().

for part in part_tree_list {
	until stages:length > part:stage {
		stages:add(list()).
	}

	if		(part:name = "launchClamp1") or
			(part:name = "noseCone") or
			(part:name = "R8winglet") or
			(part:name = "sepMotor1") or
			(part:name = "spotLight1") or
			(part:name = "spotLight2") or
			(part:name = "RCSBlock") or
			(part:name = "radialRCSTank") or
			(part:name = "trussPiece1x") or
			(part:name = "trussPiece3x") or
			(part:name = "landingLeg1") or
			(part:name = "ksp.r.largeBatteryPack") or
			(part:name = "strutConnector") {
	} else {
		stages[part:stage]:add(part).
	}
}

set i to 0.
for s in stages {
	print "stage " + i.
	
	for part in s {
		print "    " + part:name.
	}
	
	set i to i + 1.
}







