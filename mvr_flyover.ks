// PARAM mvr_flyover_latlng

clearscreen.
print "MVR FLYOVER".
print "    latlng          " + mvr_flyover_latlng.
print "    latlng:distance " + mvr_flyover_latlng:distance.
print "    latlng:bearing  " + mvr_flyover_latlng:bearing.

// wait for burn longitude

set wait_for_long_long to mvr_flyover_latlng:lng.

// calc bearing to latlong

// burn to change inclination to match above bearimg



