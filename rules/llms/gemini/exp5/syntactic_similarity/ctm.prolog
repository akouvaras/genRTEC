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
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp, I_turn),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, I_accel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, I_decel),
    union_all([I_turn, I_accel, I_decel], I).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp, I_sharp_turn),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, I_v_accel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, I_v_decel),
    relative_complement_all(I_sharp_turn, [I_v_accel, I_v_decel], I_part_A),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, I_a_accel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, I_a_decel),
    union_all([I_a_accel, I_a_decel], I_part_B),
    union_all([I_part_A, I_part_B], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, I_punctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomfortable),
    relative_complement_all(I_punctual, [I_unsafe, I_uncomfortable], I).

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
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I_temp_hot),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I_temp_cold),
    union_all([I_uncomfortable, I_unsafe, I_density, I_noise, I_temp_hot, I_temp_cold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(noise_level(Id, VehicleType)=high, I_noise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I_temp_hot),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I_temp_cold),
    union_all([I_uncomfortable, I_unsafe, I_noise, I_temp_hot, I_temp_cold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, I_non_punctual),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, I_comfort),
    union_all([I_non_punctual, I_comfort], I).