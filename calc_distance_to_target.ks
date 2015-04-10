
set t to time.

set t1 to time + eta:apoapsis.

set ps1 to positionat(ship,   t1).
set pt1 to positionat(target, t1).

set d1 to (pt1 - ps1):mag.

print "distance at ship apoapsis " + d1.

