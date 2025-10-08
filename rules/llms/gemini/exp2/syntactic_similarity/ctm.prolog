%--------------- internal_temperature -----------%

initiatedAt(internal_temperature(Id, VehicleType) = Value, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, Value), T).

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType) = Value, T) :-
    happensAt(noise_level_change(Id, VehicleType, Value), T).

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType) = Value, T) :-
    happensAt(passenger_density_change(Id, VehicleType, Value), T).

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType) = punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, early), T).

initiatedAt(punctuality(Id, VehicleType) = punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, scheduled), T).

initiatedAt(punctuality(Id, VehicleType) = non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, late), T).

initiatedAt(punctuality(Id, VehicleType) = non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType) = unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType) = very_sharp, I_Turn),
    holdsFor(abrupt_acceleration(Id, VehicleType) = very_abrupt, I_Accel),
    holdsFor(abrupt_deceleration(Id, VehicleType) = very_abrupt, I_Decel),
    union_all([I_Turn, I_Accel, I_Decel], I).

holdsFor(driving_style(Id, VehicleType) = uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType) = sharp, I_SharpTurn),
    holdsFor(abrupt_acceleration(Id, VehicleType) = very_abrupt, I_VAbruptAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType) = very_abrupt, I_VAbruptDecel),
    relative_complement_all(I_SharpTurn, [I_VAbruptAccel, I_VAbruptDecel], I_A),
    holdsFor(abrupt_acceleration(Id, VehicleType) = abrupt, I_AbruptAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType) = abrupt, I_AbruptDecel),
    union_all([I_AbruptAccel, I_AbruptDecel], I_B),
    union_all([I_A, I_B], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType) = high, I) :-
    holdsFor(punctuality(Id, VehicleType) = punctual, I_Punctual),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I_Unsafe),
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I_Uncomfortable),
    relative_complement_all(I_Punctual, [I_Unsafe, I_Uncomfortable], I).

holdsFor(driving_quality(Id, VehicleType) = medium, I) :-
    holdsFor(punctuality(Id, VehicleType) = punctual, I_Punctual),
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I_Uncomfortable),
    intersect_all([I_Punctual, I_Uncomfortable], I).

holdsFor(driving_quality(Id, VehicleType) = low, I) :-
    holdsFor(punctuality(Id, VehicleType) = non_punctual, I_NonPunctual),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I_Unsafe),
    union_all([I_NonPunctual, I_Unsafe], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType) = reducing, I) :-
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I_Uncomfortable),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I_Unsafe),
    holdsFor(passenger_density(Id, VehicleType) = high, I_Density),
    holdsFor(noise_level(Id, VehicleType) = high, I_Noise),
    holdsFor(internal_temperature(Id, VehicleType) = very_warm, I_VWarm),
    holdsFor(internal_temperature(Id, VehicleType) = very_cold, I_VCold),
    union_all([I_Uncomfortable, I_Unsafe, I_Density, I_Noise, I_VWarm, I_VCold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType) = reducing, I) :-
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I_Uncomfortable),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I_Unsafe),
    holdsFor(noise_level(Id, VehicleType) = high, I_Noise),
    holdsFor(internal_temperature(Id, VehicleType) = very_warm, I_VWarm),
    holdsFor(internal_temperature(Id, VehicleType) = very_cold, I_VCold),
    union_all([I_Uncomfortable, I_Unsafe, I_Noise, I_VWarm, I_VCold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType) = reducing, I) :-
    holdsFor(punctuality(Id, VehicleType) = non_punctual, I_NonPunctual),
    holdsFor(passenger_comfort(Id, VehicleType) = reducing, I_Comfort),
    union_all([I_NonPunctual, I_Comfort], I).