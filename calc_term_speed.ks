
lock g to ship:body:mu / (ship:body:radius + altitude)^2.

lock pres to ship:body:atm:sealevelpressure * ( constant():e ^ ( -1 * ship:altitude / (ship:body:atm:scale*1000) ) ).

lock v0 to ship:velocity:surface:mag.

lock k to (2 * ship:mass * g) / (v^2 * pres).

until 0 {
	
	print v0 + " " + k.
	
}


