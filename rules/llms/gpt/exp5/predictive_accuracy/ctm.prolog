%--------------- internal_temperature -----------%

initially(internal_temperature(_, _)=normal).

initiatedAt(internal_temperature(Id, VehicleType)=very_warm,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, very_warm), T). 

initiatedAt(internal_temperature(Id, VehicleType)=warm,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, warm), T). 

initiatedAt(internal_temperature(Id, VehicleType)=normal,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, normal), T). 

initiatedAt(internal_temperature(Id, VehicleType)=cold,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, cold), T). 

initiatedAt(internal_temperature(Id, VehicleType)=very_cold,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, very_cold), T). 

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

initially(punctuality(_, _)=punctual).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).
	
terminatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

terminatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).
	
terminatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, Iu) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp, Ivst),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, Ivaa),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, Ivad),
    union_all([Ivst, Ivaa, Ivad], Iu).
	
holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp, Isharp),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, Ia),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, Id),
    union_all([Isharp, Ia, Id], I0),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    relative_complement_all(I0, [Iu], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    union_all([Iu, Iuc], Ibad),
    relative_complement_all(Ip, [Ibad], I).

holdsFor(driving_quality(Id, VehicleType)=medium, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    intersect_all([Ip, Iuc], Im0),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    relative_complement_all(Im0, [Iu], I).

holdsFor(driving_quality(Id, VehicleType)=low, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inp),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    union_all([Inp, Iu], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, RPCI) :- 
	holdsFor(driving_style(Id, VehicleType)=uncomfortable, UCI),
	holdsFor(driving_style(Id, VehicleType)=unsafe, USI),
	holdsFor(passenger_density(Id, VehicleType)=high, HPDI),
	holdsFor(noise_level(Id, VehicleType)=high, HNLI),
	holdsFor(internal_temperature(Id, VehicleType)=very_warm, VWITI),
	holdsFor(internal_temperature(Id, VehicleType)=very_cold, VCITI),
	union_all([UCI, USI, HPDI, HNLI, VWITI, VCITI], RPCI).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, RPCI) :- 
	holdsFor(driving_style(Id, VehicleType)=uncomfortable, UCI),
	holdsFor(driving_style(Id, VehicleType)=unsafe, USI),
	holdsFor(noise_level(Id, VehicleType)=high, HNLI),
	holdsFor(internal_temperature(Id, VehicleType)=very_warm, VWITI),
	holdsFor(internal_temperature(Id, VehicleType)=very_cold, VCITI),
	union_all([UCI, USI, HNLI, VWITI, VCITI], RPCI).

%----------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, RPSI) :-
	holdsFor(punctuality(Id, VehicleType)=non_punctual, NPI),
	holdsFor(passenger_comfort(Id, VehicleType)=reducing, RPCI),
	union_all([NPI, RPCI], RPSI).

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
grounding(punctuality(Id,VehicleType)=punctual):-
    vehicle(Id, VehicleType).   
grounding(punctuality(Id,VehicleType)=non_punctual):-
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