%--------------- internal_temperature -----------%

initially(internal_temperature(_, _)=normal).

initiatedAt(internal_temperature(Id)=very_warm, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, very_warm), T).

initiatedAt(internal_temperature(Id)=warm, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, warm), T).

initiatedAt(internal_temperature(Id)=normal, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, normal), T).

initiatedAt(internal_temperature(Id)=cold, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, cold), T).

initiatedAt(internal_temperature(Id)=very_cold, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, very_cold), T).

%--------------- noise_level -----------%

initially(noise_level(_, _)=low).

initiatedAt(noise_level(Id)=low, T) :-
    happensAt(noise_level_change(Id, _VehicleType, low), T).

initiatedAt(noise_level(Id)=normal, T) :-
    happensAt(noise_level_change(Id, _VehicleType, normal), T).

initiatedAt(noise_level(Id)=high, T) :-
    happensAt(noise_level_change(Id, _VehicleType, high), T).

%--------------- passenger_density -----------%

initially(passenger_density(_, _)=low).

initiatedAt(passenger_density(Id)=low, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, low), T).

initiatedAt(passenger_density(Id)=normal, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, normal), T).

initiatedAt(passenger_density(Id)=high, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, high), T).

%--------------- punctuality -----------%

initially(punctuality(_, _)=punctual).

initiatedAt(punctuality(Id)=true, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id)=true, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id)=false, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id)=false, T) :-
    happensAt(stop_leave(Id, _VehicleType, _StopCode, early), T).

%-------------- driving_style----------------------%

initiatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(start(sharp_turn(Vehicle, _Type)=very_sharp), T).

terminatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(end(sharp_turn(Vehicle, _Type)=very_sharp), T).

initiatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(start(abrupt_acceleration(Vehicle, _Type)=very_abrupt), T).

terminatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(end(abrupt_acceleration(Vehicle, _Type)=very_abrupt), T).

initiatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(start(abrupt_deceleration(Vehicle, _Type)=very_abrupt), T).

terminatedAt(driving_style(Vehicle)=unsafe, T) :-
    happensAt(end(abrupt_deceleration(Vehicle, _Type)=very_abrupt), T).

initiatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(start(abrupt_acceleration(Vehicle, _Type)=abrupt), T),
    \+ holdsAt(abrupt_acceleration(Vehicle, _Type)=very_abrupt, T).

terminatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(end(abrupt_acceleration(Vehicle, _Type)=abrupt), T).

initiatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(start(abrupt_deceleration(Vehicle, _Type)=abrupt), T),
    \+ holdsAt(abrupt_deceleration(Vehicle, _Type)=very_abrupt, T).

terminatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(end(abrupt_deceleration(Vehicle, _Type)=abrupt), T).

initiatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(start(sharp_turn(Vehicle, _Type)=sharp), T),
    \+ holdsAt(sharp_turn(Vehicle, _Type)=very_sharp, T),
    \+ holdsAt(abrupt_acceleration(Vehicle, _Type)=very_abrupt, T),
    \+ holdsAt(abrupt_deceleration(Vehicle, _Type)=very_abrupt, T).

terminatedAt(driving_style(Vehicle)=uncomfortable, T) :-
    happensAt(end(sharp_turn(Vehicle, _Type)=sharp), T).

%-------------- driving_quality ----------------%

initiatedAt(driving_quality(Vehicle)=low, T) :-
    happensAt(start(punctuality(Vehicle)=false), T).

initiatedAt(driving_quality(Vehicle)=low, T) :-
    happensAt(start(driving_style(Vehicle)=unsafe), T).

initiatedAt(driving_quality(Vehicle)=medium, T) :-
    happensAt(start(punctuality(Vehicle)=true), T),
    holdsAt(punctuality(Vehicle)=true, T),
    happensAt(start(driving_style(Vehicle)=uncomfortable), T),
    \+ holdsAt(driving_style(Vehicle)=unsafe, T).

initiatedAt(driving_quality(Vehicle)=medium, T) :-
    happensAt(start(driving_style(Vehicle)=uncomfortable), T),
    holdsAt(punctuality(Vehicle)=true, T),
    \+ holdsAt(driving_style(Vehicle)=unsafe, T).

initiatedAt(driving_quality(Vehicle)=high, T) :-
    happensAt(start(punctuality(Vehicle)=true), T),
    \+ holdsAt(driving_style(Vehicle)=unsafe, T),
    \+ holdsAt(driving_style(Vehicle)=uncomfortable, T).

initiatedAt(driving_quality(Vehicle)=high, T) :-
    happensAt(end(driving_style(Vehicle)=uncomfortable), T),
    holdsAt(punctuality(Vehicle)=true, T),
    \+ holdsAt(driving_style(Vehicle)=unsafe, T).

%------------ passenger_comfort -------------%

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=unsafe), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=uncomfortable), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(passenger_density(Vehicle)=high), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(noise_level(Vehicle)=high), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_warm), T).

initiatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_cold), T).

terminatedAt(passenger_comfort(Vehicle)=reducing, T) :-
    happensAt(end(driving_style(Vehicle)=unsafe), T),
    \+ holdsAt(driving_style(Vehicle)=uncomfortable, T),
    \+ holdsAt(passenger_density(Vehicle)=high, T),
    \+ holdsAt(noise_level(Vehicle)=high, T),
    \+ holdsAt(internal_temperature(Vehicle)=very_warm, T),
    \+ holdsAt(internal_temperature(Vehicle)=very_cold, T).

%--------------- driver_comfort -----------------%

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=unsafe), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=uncomfortable), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(noise_level(Vehicle)=high), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_warm), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_cold), T).

terminatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(end(driving_style(Vehicle)=unsafe), T),
    \+ holdsAt(driving_style(Vehicle)=uncomfortable, T),
    \+ holdsAt(noise_level(Vehicle)=high, T),
    \+ holdsAt(internal_temperature(Vehicle)=very_warm, T),
    \+ holdsAt(internal_temperature(Vehicle)=very_cold, T).

%----------------- passenger_satisfaction ------------------%

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=unsafe), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(driving_style(Vehicle)=uncomfortable), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(noise_level(Vehicle)=high), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_warm), T).

initiatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(start(internal_temperature(Vehicle)=very_cold), T).

terminatedAt(driver_comfort(Vehicle)=reducing, T) :-
    happensAt(end(driving_style(Vehicle)=unsafe), T),
    \+ holdsAt(driving_style(Vehicle)=uncomfortable, T),
    \+ holdsAt(noise_level(Vehicle)=high, T),
    \+ holdsAt(internal_temperature(Vehicle)=very_warm, T),
    \+ holdsAt(internal_temperature(Vehicle)=very_cold, T).

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
grounding(punctuality(Id)=true):-
    vehicle(Id).   
grounding(punctuality(Id)=false):-
    vehicle(Id).
grounding(passenger_density(Id)=high):-
    vehicle(Id).
grounding(noise_level(Id)=high):-
    vehicle(Id).
grounding(internal_temperature(Id)=very_warm):-
    vehicle(Id).
grounding(internal_temperature(Id)=very_cold):-
    vehicle(Id).
grounding(driving_style(Id)=unsafe):-
    vehicle(Id).
grounding(driving_style(Id)=uncomfortable):-
    vehicle(Id).
grounding(driving_quality(Id)=high):-
    vehicle(Id).
grounding(driving_quality(Id)=medium):-
    vehicle(Id).
grounding(driving_quality(Id)=low):-
    vehicle(Id). 
grounding(passenger_comfort(Id)=reducing):-
    vehicle(Id).
grounding(driver_comfort(Id)=reducing):-
    vehicle(Id).
grounding(passenger_satisfaction(Id)=reducing):-
    vehicle(Id).