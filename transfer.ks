// PARAMETER transfer_to

set hier_ship to list().

set b to ship.
until 0 {
	if b = sun {
		break.
	}
	
	hier_ship:add(b:obt:body).
	
	set b to b:obt:body.
}

print hier_ship.

set hier_body to list().

set b to transfer_to.
until 0 {
	if b = sun {
		break.
	}
	
	hier_body:add(b:obt:body).
	
	set b to b:obt:body.
}

print hier_body.

