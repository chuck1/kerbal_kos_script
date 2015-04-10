// PARAMETER calc_transfer_ip_body_2



set body_1 to ship:body.
set body_2 to calc_transfer_ip_body_2.

set  r1 to body_1:obt:semimajoraxis.
set  r2 to body_2:obt:semimajoraxis.

lock rs to ship:obt:semimajoraxis.



set get_soi_body to body_1.
run get_soi.

set soi to get_soi_ret.

set t_H to constant():pi * sqrt((r1 + r2)^3 / (8 * sun:mu)).

set calc_transfer_ip_phase to 180 * (1 - sqrt(sun:mu / r2) * t_H / r2 / constant():pi).

// velocity edge of ship:body SOI

set dv to sqrt(sun:mu / r1) * (sqrt(2 * r2 / (r1 + r2)) - 1).

//set vb1 to (body_1:velocity:orbit - sun:velocity:orbit):mag.

//set v1 to vb1 + dv.

// velocity at parking orbit

//set ve to sqrt(
//	(rs * (soi * v1^2 - 2 * body_1:mu) + 2 * soi * body_1:mu) /
//	(rs * soi)).
set ve to sqrt(
	(rs * (soi * dv^2 - 2 * body_1:mu) + 2 * soi * body_1:mu) /
	(rs * soi)).

set vp to (ship:velocity:orbit - ship:body:velocity:orbit):mag.

// ejection burn angle

set ep to ve^2 / 2 - ship:body:mu / rs.

set h to vcrs(
	ship:position       - ship:body:position,
	ship:velocity:orbit - ship:body:velocity:orbit):mag.

set e to sqrt(1 + 2 * ep * h^2 / body_1:mu^2).

set calc_transfer_ip_theta to 180 - arccos(1/e).

set calc_transfer_ip_ejection_burn to ve - vp.

print "planetary phase angle " + calc_transfer_ip_phase.
print "planetary deltav      " + dv.
//print "body 1 v              " + vb1.
print "parking obt v         " + vp.
print "ejection velocity     " + ve.
print "ejection angle        " + calc_transfer_ip_theta.
print "ejection burn         " + calc_transfer_ip_ejection_burn.






