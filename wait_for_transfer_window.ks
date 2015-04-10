declare parameter o.

print "wait for transfer window".

set r1 to ship:altitude + ship:body:radius.
set r2 to o:altitude + ship:body:radius.

set phi_rad to constant():pi * (1 - (1 / 2 / sqrt(2)) * sqrt(((r1/r2)+1)^3)).
set phi to 180 / constant():pi * phi_rad.

if phi < 0 {
	//set phi to 360 + phi.
}

print "transfer angle: " + phi.

set wait_for_angle_body to o.
set wait_for_angle_angle to phi.
run wait_for_angle.

