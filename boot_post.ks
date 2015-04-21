declare parameter ret.

if ret = 0 {
	print "mission complete".
	delete "boot.ks" from 1.
}

reboot.


