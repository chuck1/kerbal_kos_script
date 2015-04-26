run lib_math.
run lib_obt.

if 0 {


local ana is 0.
local ana0 is 0.
local c is 0.

until 0 {

	local aop is ship:obt:argumentofperiapsis.
	local lan is ship:obt:lan.
	local lan2 is ship:obt:lan + c.
	local i is ship:obt:inclination.
	
	local anv is V(1,0,0) * cos(ship:obt:lan) + V(0,0,1) * sin(ship:obt:lan).
	
	local r is ship:position - ship:body:position.

	set ana0 to ana.
	set ana  to math_clamp_angle(ship:obt:trueanomaly + aop).
	
	set xz to math_clamp_angle(arctan2(r:z,r:x)).
	
	if ana < ana0 {
		// zero crossing
		set c to math_clamp_angle(xz - lan).
	}
	
	clearscreen.
	print "lan  ship " + ship:obt:lan.
	print "aop       " + aop.
	print "i         " + i.
	print "ana       " + ana.
	
	print "h         " + obt_h_for(ship):normalized.
	print "r         " + r:normalized.
	//print vang(anv, r).
	print "xz angle  " + xz.
	print "c         " + c.
	print "lan2 ship " + lan2.

	wait 0.01.
	
	
}

} else {

local os1 is obt_struc_ctor_from_obt(ship:obt).
local os2 is obt_struc_ctor_current_for(ship).

local anv_1 is obt_struc_get_anv(os1).
local anv_2 is obt_struc_get_anv(os2).

print 	round(os1[0]:x,2) + "    " + round(os2[0]:x,2).
print 	round(os1[0]:y,2) + "    " + round(os2[0]:y,2).
print 	round(os1[0]:z,2) + "    " + round(os2[0]:z,2).
print 	round(os1[1]:x,5) + "    " + round(os2[1]:x,5).
print 	round(os1[1]:y,5) + "    " + round(os2[1]:y,5).
print 	round(os1[1]:z,5) + "    " + round(os2[1]:z,5).

print 	round(anv_1:x,5) + "    " + round(anv_2:x,5).
print 	round(anv_1:y,5) + "    " + round(anv_2:y,5).
print 	round(anv_1:z,5) + "    " + round(anv_2:z,5).





}

