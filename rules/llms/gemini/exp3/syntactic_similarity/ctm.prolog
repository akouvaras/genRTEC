%--------------- internal_temperature -----------%

initiatedAt(internal_temperature(Id, VehicleType)=Value, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, Value), T).

terminatedAt(internal_temperature(Id, VehicleType)=OldValue, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, NewValue), T),
    holdsAt(internal_temperature(Id, VehicleType)=OldValue, T),
    NewValue \== OldValue.

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=Value, T) :-
    happensAt(noise_level_change(Id, VehicleType, Value), T).

terminatedAt(noise_level(Id, VehicleType)=OldValue, T) :-
    happensAt(noise_level_change(Id, VehicleType, NewValue), T),
    holdsAt(noise_level(Id, VehicleType)=OldValue, T),
    NewValue \== OldValue.

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=Value, T) :-
    happensAt(passenger_density_change(Id, VehicleType, Value), T).

terminatedAt(passenger_density(Id, VehicleType)=OldValue, T) :-
    happensAt(passenger_density_change(Id, VehicleType, NewValue), T),
    holdsAt(passenger_density(Id, VehicleType)=OldValue, T),
    NewValue \== OldValue.

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, early), T).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, scheduled), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _, early), T).

terminatedAt(punctuality(Id, VehicleType)=OldValue, T) :-
    happensAt(start(punctuality(Id, VehicleType)=NewValue), T),
    OldValue \== NewValue.

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp, I1),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, I2),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, I3),
    union_all([I1, I2, I3], I).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp, I_sharp),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, I_vaccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, I_vdecel),
    union_all([I_vaccel, I_vdecel], I_very_abrupt),
    relative_complement_all(I_sharp, [I_very_abrupt], I_cond_A),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, I_accel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, I_decel),
    union_all([I_accel, I_decel], I_cond_B),
    union_all([I_cond_A, I_cond_B], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, I_punctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomfortable),
    union_all([I_unsafe, I_uncomfortable], I_bad_style),
    relative_complement_all(I_punctual, [I_bad_style], I).

holdsFor(driving_quality(Id, VehicleType)=medium, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, I_punctual),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomfortable),
    intersect_all([I_punctual, I_uncomfortable], I).

holdsFor(driving_quality(Id, VehicleType)=low, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, I_non_punctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    union_all([I_non_punctual, I_unsafe], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(passenger_density(Id, VehicleType)=high, I_density),
    holdsFor(noise_level(Id, VehicleType)=high, I_noise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I_temp_vw),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I_temp_vc),
    union_all([I_uncomfortable, I_unsafe, I_density, I_noise, I_temp_vw, I_temp_vc], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(noise_level(Id, VehicleType)=high, I_noise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I_temp_vw),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I_temp_vc),
    union_all([I_uncomfortable, I_unsafe, I_noise, I_temp_vw, I_temp_vc], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, I_non_punctual),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, I_comfort_reducing),
    union_all([I_non_punctual, I_comfort_reducing], I).