
function get_destination {
	parameter s.

	if s = "mun_arch" {
		return mun_arch.
	} else if s = "kerbin_vab" {
		return kerbin_vab.
	}
}

print "loaded library get".

