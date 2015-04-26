function sprint_clock {
	parameter t.
	
	set t to round(t,0).

	local s is mod(t, 60).
	
	set t to t - s.
	
	local m is mod(t / 60, 60).
	
	set t to t - 60 * m.
	
	local h is mod(t / 3600, 6).
	
	set t to t - 3600 * h.
	
	local d is t / (3600 * 6).
	
	return (d + "d, " + h + ":" + m + ":" + s).
}

print "loaded library print".

