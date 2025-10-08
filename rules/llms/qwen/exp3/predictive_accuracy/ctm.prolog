%--------------- internal_temperature -----------%

initially(internal_temperature(_, _)=normal).

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

initially(noise_level(_, _)=low).


initiatedAt(noise_level(Id, VehicleType)=low, T) :-
    happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType)=normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType)=high, T) :-
    happensAt(noise_level_change(Id, VehicleType, high), T).

%--------------- passenger_density -----------%

initially(passenger_density(_, _)=low).

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
    \+ holdsAt(abrupt_acceleration(Id, VehicleType)=very_abrupt, T),
    \+ holdsAt(abrupt_deceleration(Id, VehicleType)=very_abrupt, T).

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

%----------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(non_punctual(Id, VehicleType)=true, I_nonpunc),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, I_uncomf),
    union_all([I_nonpunc, I_uncomf], I),
    I \= [].

% These input statically determined fluents arrive in the form of intervals in input streams.
collectIntervals(abrupt_acceleration(_,_)=abrupt).
collectIntervals(abrupt_acceleration(_,_)=very_abrupt).
collectIntervals(abrupt_deceleration(_,_)=abrupt).
collectIntervals(abrupt_deceleration(_,_)=very_abrupt).
collectIntervals(sharp_turn(_,_)=sharp).
collectIntervals(sharp_turn(_,_)=very_sharp).

% The elements of these domains are derived from the ground arguments of input entitites
dynamicDomain(vehicle(_,_)).

% Grounding for input entities:
grounding(stop_enter(Id, VehicleType,_,_)):-
    vehicle(Id, VehicleType).
grounding(stop_leave(Id, VehicleType,_,_)):-
    vehicle(Id, VehicleType).
grounding(internal_temperature_change(Id, VehicleType,_)):-
    vehicle(Id, VehicleType).
grounding(noise_level_change(Id, VehicleType,_)):-
    vehicle(Id, VehicleType).
grounding(passenger_density_change(Id, VehicleType,_)):-
    vehicle(Id, VehicleType).
grounding(punctuality_change(Id,VehicleType,punctual)):-
    vehicle(Id, VehicleType).
grounding(punctuality_change(Id,VehicleType,non_punctual)):-
    vehicle(Id, VehicleType).
grounding(abrupt_acceleration(Id,VehicleType)=abrupt):-
    vehicle(Id, VehicleType). 
grounding(abrupt_acceleration(Id,VehicleType)=very_abrupt):-
    vehicle(Id, VehicleType). 
grounding(abrupt_deceleration(Id,VehicleType)=abrupt):-
    vehicle(Id, VehicleType). 
grounding(abrupt_deceleration(Id,VehicleType)=very_abrupt):-
    vehicle(Id, VehicleType). 
grounding(sharp_turn(Id,VehicleType)=sharp):-
    vehicle(Id, VehicleType). 
grounding(sharp_turn(Id,VehicleType)=very_sharp):-
    vehicle(Id, VehicleType).

% Grounding for output entities:
grounding(punctual(Id,VehicleType)=true):-
    vehicle(Id, VehicleType).   
grounding(non_punctual(Id,VehicleType)=true):-
    vehicle(Id, VehicleType).
grounding(passenger_density(Id,VehicleType)=high):-
    vehicle(Id, VehicleType).
grounding(noise_level(Id,VehicleType)=high):-
    vehicle(Id, VehicleType).
grounding(internal_temperature(Id,VehicleType)=very_warm):-
    vehicle(Id, VehicleType).
grounding(internal_temperature(Id,VehicleType)=very_cold):-
    vehicle(Id, VehicleType).
grounding(driving_style(Id,VehicleType)=unsafe):-
    vehicle(Id, VehicleType).
grounding(driving_style(Id,VehicleType)=uncomfortable):-
    vehicle(Id, VehicleType).
grounding(driving_quality(Id,VehicleType)=high):-
    vehicle(Id, VehicleType).
grounding(driving_quality(Id,VehicleType)=medium):-
    vehicle(Id, VehicleType).
grounding(driving_quality(Id,VehicleType)=low):-
    vehicle(Id, VehicleType). 
grounding(passenger_comfort(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).
grounding(driver_comfort(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).
grounding(passenger_satisfaction(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).