// PARAMETER mvr_inc_change_angle

lock normal to vcrs(
	ship:position - ship:body:position,
	ship:vecocity:orbit - ship:body:velocity:orbit):normalized.

lock radial to vcrs(
	ship:vecocity:orbit,
	normal):normalized.

lock steer to (normal * mvr_inc_change_angle):normalized:direction.

lock steering to steer.

set normal_0 to normal.

lock throttle to 1.

until vang(normal_0, normal) < 0.1 {
	
	if vang(steering:vector, ship:facing:vector) > 1 {
		lock throttle to 0.
	} else {
		lock throttle to 1.
	}
}



