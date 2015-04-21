
function util_ship_jettison_fairings {

	local p  is 0.
	local pl is 0.
	local module is 0.

	list parts in pl.
	
	for p in pl {
		if p:name = "KzProcFairingSide1" {
			p:getmodule("ProceduralFairingDecoupler"):doevent("jettison").
		}
	}

}

function util_ship_stage_burn {

	local el is 0.
	local e is 0.	

	list engines in el.
	
	for e in el {
		if e:flameout {
			stage.
			break.
		}
	}
	
	until not (ship:maxthrust = 0) {
		stage.
		wait 0.5.
	}
	
}

function util_stage_all {
	
}

print "loaded library util_ship".

