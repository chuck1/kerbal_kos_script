declare parameter calc_transfer_phase_target.

set calc_transfer_phase_r1 to ship:obt:semimajoraxis.

set calc_transfer_phase_r2 to calc_transfer_phase_target:obt:semimajoraxis.

//set frac_t to (ship:altitude + burn_to_encounter_body:altitude + 2 * ship:body:radius) / (2 * (ship:body:radius + burn_to_encounter_body:altitude)).
//set theta to 360 * frac_t.
//set phi to 180 - theta.

set calc_transfer_phase_phase_rad to constant():pi * (1 - (1 / 2 / sqrt(2)) * sqrt(((calc_transfer_phase_r1/calc_transfer_phase_r2)+1)^3)).
set calc_transfer_phase_phase to 180 / constant():pi * calc_transfer_phase_phase_rad.



