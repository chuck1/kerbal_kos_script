lock steering to up + R(0,0,180).

set g to ship:body:mu / ship:body:radius^2.
lock a to ship:maxthrust / ship:mass.

lock timetostop to -1.0 * ship:verticalspeed / (a - g).

set scal1 to 1.0.

if ship:body:atm:exists {
lock timetoterm to scal1 * -1.0 * ((-1.0 * ship:termvelocity) - ship:verticalspeed) / g.
lock disttoterm to -1.0 * (ship:verticalspeed * timetoterm - 0.5 * g * timetoterm^2).
lock delvel to abs((ship:verticalspeed + ship:termvelocity) / ship:termvelocity).
} else {
    lock timetoterm to 0.
    lock disttoterm to 0.
    lock delvel to 1.
}

until alt:radar < 400 {

    if ship:body:atm:exists {
    // close to term
    if delvel < 0.1 {
        set timetoimpact to alt:radar / ship:termvelocity.
        set meth to 0.
    } else if alt:radar < disttoterm {
        // not going to reach term
        
        set q to sqrt(ship:verticalspeed^2 + 2.0 * g * alt:radar).
        set t0 to (-1.0 * ship:verticalspeed + q) / -g.
        set t1 to (-1.0 * ship:verticalspeed - q) / -g.
        if t0 < 0 {
            set timetoimpact to t1.
        } else if t1 < 0 {
            set timetoimpact to t0.
        } else {
            set timetoimpact to min(t0, t1).
        }
        set meth to 1.
    } else {
        // going to reach term
        set timetoimpact to timetoterm + (alt:radar - disttoterm) / ship:termvelocity.
        set meth to 2.
    }
    } else {
        // no atmosphere, not going to reach term
        
        set q to sqrt(ship:verticalspeed^2 + 2.0 * g * alt:radar).
        set t0 to (-1.0 * ship:verticalspeed + q) / -g.
        set t1 to (-1.0 * ship:verticalspeed - q) / -g.
        if t0 < 0 {
            set timetoimpact to t1.
        } else if t1 < 0 {
            set timetoimpact to t0.
        } else {
            set timetoimpact to min(t0, t1).
        }
        set meth to 1.
    }

    print "timetoterm " + timetoterm.
    print "disttoterm " + disttoterm.
    print "alt:radar " + alt:radar.
    print "timetoimpact " + meth + " " + timetoimpact.
    
    if timetoimpact < (timetostop + 1) {
        print "warning!".
        lock throttle to 1.
        wait until ship:verticalspeed > 0.
        lock throttle to 0.
    }

    wait 0.2.
}

when alt:radar < 100 then set legs to true.

lock steering to R(ship:srfretrograde:pitch, ship:srfretrograde:yaw, 180).


// general purpose PID
set Y to 0.

// select input and output
lock X to ship:verticalspeed.
lock tar to -0.1 * alt:radar - 1.0.
lock throttle to Y.

lock P to tar - X.
set I to 0.
set D to 0.
set P0 to 0.

set Kp to 0.01.
set Ki to 0.0.
set Kd to 0.006.

lock dY to Kp * P + Ki * I + Kd * D.

set t0 to time:seconds.
//until alt:radar < 8 {
until ship:verticalspeed > -0.1 and alt:radar < 20 {
set dt to time:seconds - t0.
if dt > 0 {
    set I to I + P * dt.
    set D to (P - P0) / dt.

    if Ki > 0 {
        set I to min(1.0/Ki, max(-1.0/Ki, I)).
    }

    set Y to min(1, max(0, Y + dY)).

    set P0 to P.
    set t0 to time:seconds.

    //print "retr " + ship:srfretrograde.
    //print "ship " + ship:facing.
    print "radar " + alt:radar.

    //print Y.
}
wait 0.1.

}

lock throttle to 0.
