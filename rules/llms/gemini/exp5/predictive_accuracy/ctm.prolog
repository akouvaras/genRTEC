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

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp, ITurn),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, IAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, IDecel),
    union_all([ITurn, IAccel, IDecel], I).

holdsFor(uncomfortable_turn(Id, VehicleType)=true, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp, ITurn),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, IAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, IDecel),
    relative_complement_all(ITurn, [IAccel, IDecel], I).

holdsFor(uncomfortable_accel_decel(Id, VehicleType)=true, I) :-
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, IAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, IDecel),
    union_all([IAccel, IDecel], I).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(uncomfortable_turn(Id, VehicleType)=true, ITurn),
    holdsFor(uncomfortable_accel_decel(Id, VehicleType)=true, IAccelDecel),
    union_all([ITurn, IAccelDecel], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, IPunctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, IUnsafe),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, IUncomfortable),
    relative_complement_all(IPunctual, [IUnsafe, IUncomfortable], I).

holdsFor(driving_quality(Id, VehicleType)=medium, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, IPunctual),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, IUncomfortable),
    intersect_all([IPunctual, IUncomfortable], I).

holdsFor(driving_quality(Id, VehicleType)=low, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, INonPunctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, IUnsafe),
    union_all([INonPunctual, IUnsafe], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, IUncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, IUnsafe),
    holdsFor(passenger_density(Id, VehicleType)=high, IDensity),
    holdsFor(noise_level(Id, VehicleType)=high, INoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, ITempWarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, ITempCold),
    union_all([IUncomfortable, IUnsafe, IDensity, INoise, ITempWarm, ITempCold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, IUncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, IUnsafe),
    holdsFor(noise_level(Id, VehicleType)=high, INoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, ITempWarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, ITempCold),
    union_all([IUncomfortable, IUnsafe, INoise, ITempWarm, ITempCold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, INonPunctual),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, IComfort),
    union_all([INonPunctual, IComfort], I).

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
grounding(uncomfortable_turn(Id,VehicleType)=true):-
    vehicle(Id, VehicleType).
grounding(uncomfortable_accel_decel(Id,VehicleType)=true):-
    vehicle(Id, VehicleType).
grounding(driving_quality(Id,VehicleType)=low):-
    vehicle(Id, VehicleType). 
grounding(passenger_comfort(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).
grounding(driver_comfort(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).
grounding(passenger_satisfaction(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).