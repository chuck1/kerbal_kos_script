

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


# equations

                           elliptic        |  hyperbolic 

v^2                                 mu(2/r - 1/a)

r                                   p/(1 + e cos(ta))   

p, semi-latus rectum                    a(1-e^2)            

r periapsis                              a(1-e)

r apoapsis                               a(1+e)
                                           
a, semimajoraxis        a > 0              |  a < 0
                                           |
e                       sqrt(1 - b^2/a^2)  |  sqrt(1 + b^2/a^2)



# bugs
1. when using programs with parameters, sometimes get "argument out of range" error. no idea why.
2. when using functions, sometimes get "wrong # of arguments" error when exiting the function. no idea why. seems like it could be related to above bug.
3. sometimes get "undefined variable" error when using function parameters for no apparent reason.
4. using ksm files causes "key already in dictionary" error sometimes when trying to run ksm file.



# controlling altitude in space...
up is positive

if above altitude, wait for descent, do suicide burn...

vf^2 - vi^2 = 2 (a - g) d

vf is 0

-vi^2 = 2 (a - g) d

a = -vi^2 / 2 / d + g


if below altitude, set vertspeed then coast

vf still 0

vi = sqrt(2 g d)







