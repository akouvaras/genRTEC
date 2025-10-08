%--------------- internal_temperature -----------%

initiatedAt(internal_temperature(Id, VehicleType) = very_warm, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, very_warm), T).

initiatedAt(internal_temperature(Id, VehicleType) = warm, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, warm), T).

initiatedAt(internal_temperature(Id, VehicleType) = normal, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, normal), T).

initiatedAt(internal_temperature(Id, VehicleType) = cold, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, cold), T).

initiatedAt(internal_temperature(Id, VehicleType) = very_cold, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, very_cold), T).

terminatedAt(internal_temperature(Id, VehicleType) = very_warm, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, _NewTemperature), T),
    _NewTemperature \= very_warm.

terminatedAt(internal_temperature(Id, VehicleType) = warm, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, _NewTemperature), T),
    _NewTemperature \= warm.

terminatedAt(internal_temperature(Id, VehicleType) = normal, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, _NewTemperature), T),
    _NewTemperature \= normal.

terminatedAt(internal_temperature(Id, VehicleType) = cold, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, _NewTemperature), T),
    _NewTemperature \= cold.

terminatedAt(internal_temperature(Id, VehicleType) = very_cold, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, _NewTemperature), T),
    _NewTemperature \= very_cold.

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType) = low, T) :-
    happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType) = normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType) = high, T) :-
    happensAt(noise_level_change(Id, VehicleType, high), T).

terminatedAt(noise_level(Id, VehicleType) = low, T) :-
    happensAt(noise_level_change(Id, VehicleType, _NewLevel), T),
    _NewLevel \= low.

terminatedAt(noise_level(Id, VehicleType) = normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, _NewLevel), T),
    _NewLevel \= normal.

terminatedAt(noise_level(Id, VehicleType) = high, T) :-
    happensAt(noise_level_change(Id, VehicleType, _NewLevel), T),
    _NewLevel \= high.

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType) = low, T) :-
    happensAt(passenger_density_change(Id, VehicleType, low), T).

initiatedAt(passenger_density(Id, VehicleType) = normal, T) :-
    happensAt(passenger_density_change(Id, VehicleType, normal), T).

initiatedAt(passenger_density(Id, VehicleType) = high, T) :-
    happensAt(passenger_density_change(Id, VehicleType, high), T).

terminatedAt(passenger_density(Id, VehicleType) = low, T) :-
    happensAt(passenger_density_change(Id, VehicleType, _NewDensity), T),
    _NewDensity \= low.

terminatedAt(passenger_density(Id, VehicleType) = normal, T) :-
    happensAt(passenger_density_change(Id, VehicleType, _NewDensity), T),
    _NewDensity \= normal.

terminatedAt(passenger_density(Id, VehicleType) = high, T) :-
    happensAt(passenger_density_change(Id, VehicleType, _NewDensity), T),
    _NewDensity \= high.

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType) = punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType) = punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType) = non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType) = non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType) = punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

terminatedAt(punctuality(Id, VehicleType) = punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType) = non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType) = non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType) = unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType) = very_sharp, I1),
    holdsFor(abrupt_acceleration(Id, VehicleType) = very_abrupt, I2),
    holdsFor(abrupt_deceleration(Id, VehicleType) = very_abrupt, I3),
    union_all([I1, I2, I3], I).

holdsFor(driving_style(Id, VehicleType) = uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType) = sharp, I1),
    holdsFor(abrupt_acceleration(Id, VehicleType) = very_abrupt, I2),
    holdsFor(abrupt_deceleration(Id, VehicleType) = very_abrupt, I3),
    holdsFor(abrupt_acceleration(Id, VehicleType) = abrupt, I4),
    holdsFor(abrupt_deceleration(Id, VehicleType) = abrupt, I5),
    union_all([I2, I3], I_very_abrupt),
    relative_complement_all(I1, [I_very_abrupt], I1_clean),
    union_all([I1_clean, I4, I5], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType) = high, I) :-
    holdsFor(punctuality(Id, VehicleType) = punctual, I1),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I2),
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I3),
    union_all([I2, I3], I_poor_driving),
    relative_complement_all(I1, [I_poor_driving], I).

holdsFor(driving_quality(Id, VehicleType) = medium, I) :-
    holdsFor(punctuality(Id, VehicleType) = punctual, I1),
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I2),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I3),
    relative_complement_all(I2, [I3], I2_only_uncomfortable),
    intersect_all([I1, I2_only_uncomfortable], I).

holdsFor(driving_quality(Id, VehicleType) = low, I) :-
    holdsFor(punctuality(Id, VehicleType) = non_punctual, I1),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I2),
    union_all([I1, I2], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType) = reducing, I) :-
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I1),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I2),
    holdsFor(passenger_density(Id, VehicleType) = high, I3),
    holdsFor(noise_level(Id, VehicleType) = high, I4),
    holdsFor(internal_temperature(Id, VehicleType) = very_warm, I5),
    holdsFor(internal_temperature(Id, VehicleType) = very_cold, I6),
    union_all([I1, I2, I3, I4, I5, I6], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType) = reducing, I) :-
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I1),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I2),
    holdsFor(noise_level(Id, VehicleType) = high, I3),
    holdsFor(internal_temperature(Id, VehicleType) = very_warm, I4),
    holdsFor(internal_temperature(Id, VehicleType) = very_cold, I5),
    union_all([I1, I2, I3, I4, I5], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType) = reducing, I) :-
    holdsFor(punctuality(Id, VehicleType) = non_punctual, I1),
    holdsFor(passenger_comfort(Id, VehicleType) = reducing, I2),
    union_all([I1, I2], I).