

# script types

- transfer\_\*
    - put the ship in orbit around a specific body
- mvr\_\*
- power\_land
- go\_to\_\*
    - travel (using various methods) to a latlng location on the surface of a body


# equations

true anomaly from semimajor, eccentricity, radius

nu = nu(a, e, r)

a = a(ra, rp)
a = (ra + rp) / 2

e = e(ra, rp)
e = (ra - rp) / (ra + rp)

# atmosphere modelling

what i need:

input:
position 0 with radial and tangential
speeds vr and vt and radius r\_0
output:
change in true anomaly and final velocities.

nu, vr\_1, vt\_1 = f(vr\_0, vt\_0, r\_0, r\_1)






