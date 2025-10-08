%--------------- internal_temperature -----------%

initiatedAt(internal_temperature(Id, VehicleType)=very_warm, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, very_warm), T).

initiatedAt(internal_temperature(Id, VehicleType)=warm, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, warm), T).

initiatedAt(internal_temperature(Id, VehicleType)=normal, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, normal), T).

initiatedAt(internal_temperature(Id, VehicleType)=cold, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, cold), T).

initiatedAt(internal_temperature(Id, VehicleType)=very_cold, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, very_cold), T).

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=low, T) :-
    happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType)=normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType)=high, T) :-
    happensAt(noise_level_change(Id, VehicleType, high), T).

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=low, T) :-
    happensAt(passenger_density_change(Id, VehicleType, low), T).

initiatedAt(passenger_density(Id, VehicleType)=normal, T) :-
    happensAt(passenger_density_change(Id, VehicleType, normal), T).

initiatedAt(passenger_density(Id, VehicleType)=high, T) :-
    happensAt(passenger_density_change(Id, VehicleType, high), T).

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp, I1),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, I2),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, I3),
    union_all([I1, I2, I3], I).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp, Ia1),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, Ia2),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, Ia3),
    relative_complement_all(Ia1, [Ia2, Ia3], I_caseA),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, Ib1),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, Ib1_ex),
    relative_complement_all(Ib1, [Ib1_ex], I_caseB_part1),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, Ic1),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, Ic1_ex),
    relative_complement_all(Ic1, [Ic1_ex], I_caseC_part1),
    union_all([I_caseB_part1, I_caseC_part1], I_caseBC),
    union_all([I_caseA, I_caseBC], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=low, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, I1),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I2),
    union_all([I1, I2], I).

holdsFor(driving_quality(Id, VehicleType)=medium, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, I_punctual),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomf),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    relative_complement_all(I_uncomf, [I_unsafe], I_uncomf_safe),
    intersect_all([I_punctual, I_uncomf_safe], I).

holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, I_punctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomf),
    relative_complement_all(I_punctual, [I_unsafe, I_uncomf], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I1),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I2),
    holdsFor(passenger_density(Id, VehicleType)=high, I3),
    holdsFor(noise_level(Id, VehicleType)=high, I4),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I5a),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I5b),
    union_all([I1, I2, I3, I4, I5a, I5b], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I1),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I2),
    holdsFor(noise_level(Id, VehicleType)=high, I3),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I4a),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I4b),
    union_all([I1, I2, I3, I4a, I4b], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, I1),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, I2),
    union_all([I1, I2], I).