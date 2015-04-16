// util_jettison_fairings

list parts in util_jettison_fairings_pl.

for util_jettison_fairings_p in util_jettison_fairings_pl {
	if util_jettison_fairings_p:name = "KzProcFairingSide1" {
		set util_jettison_fairings_module to
			util_jettison_fairings_p:getmodule("ProceduralFairingDecoupler").
		util_jettison_fairings_module:doevent("jettison").
	}
}



