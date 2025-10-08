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

initiatedAt(punctual(Id, VehicleType)=true, T) :-
    happensAt(stop_enter(Id, VehicleType, _, early), T).

initiatedAt(punctual(Id, VehicleType)=true, T) :-
    happensAt(stop_enter(Id, VehicleType, _, scheduled), T).

initiatedAt(non_punctual(Id, VehicleType)=true, T) :-
    happensAt(stop_enter(Id, VehicleType, _, late), T).

initiatedAt(non_punctual(Id, VehicleType)=true, T) :-
    happensAt(stop_leave(Id, VehicleType, _, early), T).

%-------------- driving_style----------------------%

initiatedAt(driving_style(Id, VehicleType)=unsafe, T) :-
    happensAt(start(sharp_turn(Id, VehicleType)=very_sharp), T).

initiatedAt(driving_style(Id, VehicleType)=unsafe, T) :-
    happensAt(start(abrupt_acceleration(Id, VehicleType)=very_abrupt), T).

initiatedAt(driving_style(Id, VehicleType)=unsafe, T) :-
    happensAt(start(abrupt_deceleration(Id, VehicleType)=very_abrupt), T).

initiatedAt(driving_style(Id, VehicleType)=uncomfortable, T) :-
    happensAt(start(sharp_turn(Id, VehicleType)=sharp), T),
    not holdsAt(abrupt_acceleration(Id, VehicleType)=very_abrupt, T),
    not holdsAt(abrupt_deceleration(Id, VehicleType)=very_abrupt, T).

initiatedAt(driving_style(Id, VehicleType)=uncomfortable, T) :-
    happensAt(start(abrupt_acceleration(Id, VehicleType)=abrupt), T).

initiatedAt(driving_style(Id, VehicleType)=uncomfortable, T) :-
    happensAt(start(abrupt_acceleration(Id, VehicleType)=very_abrupt), T).

initiatedAt(driving_style(Id, VehicleType)=uncomfortable, T) :-
    happensAt(start(abrupt_deceleration(Id, VehicleType)=abrupt), T).

initiatedAt(driving_style(Id, VehicleType)=uncomfortable, T) :-
    happensAt(start(abrupt_deceleration(Id, VehicleType)=very_abrupt), T).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctual(Id, VehicleType)=true, I_punctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomf),
    relative_complement_all(I_punctual, [I_unsafe, I_uncomf], I),
    I \= [].

holdsFor(driving_quality(Id, VehicleType)=medium, I) :-
    holdsFor(punctual(Id, VehicleType)=true, I_punctual),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomf),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    relative_complement_all(I_punctual, [I_unsafe], I_punct_not_unsafe),
    intersect_all([I_punct_not_unsafe, I_uncomf], I),
    I \= [].

holdsFor(driving_quality(Id, VehicleType)=low, I) :-
    holdsFor(non_punctual(Id, VehicleType)=true, I_nonpunc),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    union_all([I_nonpunc, I_unsafe], I),
    I \= [].

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomf),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(passenger_density(Id, VehicleType)=high, I_dense),
    holdsFor(noise_level(Id, VehicleType)=high, I_noisy),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I_hot),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I_cold),
    union_all([I_hot, I_cold], I_extreme_temp),
    union_all([I_uncomf, I_unsafe, I_dense, I_noisy, I_extreme_temp], I),
    I \= [].

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, I_uncomf),
    holdsFor(driving_style(Id, VehicleType)=unsafe, I_unsafe),
    holdsFor(noise_level(Id, VehicleType)=high, I_noisy),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, I_hot),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, I_cold),
    union_all([I_hot, I_cold], I_extreme_temp),
    union_all([I_uncomf, I_unsafe, I_noisy, I_extreme_temp], I),
    I \= [].

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(non_punctual(Id, VehicleType)=true, I_nonpunc),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, I_uncomf),
    union_all([I_nonpunc, I_uncomf], I),
    I \= [].