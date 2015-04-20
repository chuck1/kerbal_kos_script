

// calc_suborbital_l
// calc_suborbital_alt
// calc_suborbital_apo

set l to calc_suborbital_l.

set calc_suborbital_r_apo to calc_suborbital_apo + ship:body:radius.

//set r1 to alt1 + ship:body:radius.
//set r2 to alt2 + ship:body:radius.


//set e to (r1 - r2) / den.
//set e to 0.5.

//set l to (r2 * r1 * (cos(p2) - cos(p1))) / den.
//set a to l / (1 - ecc^2).

//set c to ship:body:radius / 2.

//set a to c / e.
//set l to (1 - e^2) * a.

set a to calc_suborbital_r_apo^2 / (2 * calc_suborbital_r_apo - l).

//set a1 to (l + sqrt(l^2 + 4 * c^2)) / 2.
//set a2 to (l - sqrt(l^2 + 4 * c^2)) / 2.

//print "a1 " + a1.
//print "a2 " + a2.
//print "l  " + l.

//set a to a1.

set b to sqrt(l * a).

set e to sqrt(1 - b^2/a^2).

// =======================

set r to calc_suborbital_alt + ship:body:radius.

set arg to (l/r - 1) / e.

print "e   " + e.
//print "c   " + c.
print "l   " + l.

print "a   " + a.


print "arg " + arg.



//set ta1 to arccos((l - r1) / (r1 * e)).
set ta1 to arccos(arg).

set ta2 to 360 - ta1.

set calc_suborbital_v1r to sqrt(ship:body:mu / l) * e * sin(ta1).

set calc_suborbital_v1t to sqrt(ship:body:mu / l) * (1 + e * cos(ta1)).

print "ta1 " + ta1.
print "ta2 " + ta2.

set calc_suborbital_pitch1 to arctan2(calc_suborbital_v1r,  calc_suborbital_v1t).

print "v1r " + calc_suborbital_v1r.
print "v1t " + calc_suborbital_v1t.








