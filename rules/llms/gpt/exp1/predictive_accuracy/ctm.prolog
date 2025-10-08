%--------------- internal_temperature -----------%

initially(internal_temperature(_, _)=normal).

initiatedAt(internal_temperature(Id) = very_warm, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, very_warm), T).

initiatedAt(internal_temperature(Id) = warm, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, warm), T).

initiatedAt(internal_temperature(Id) = normal, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, normal), T).

initiatedAt(internal_temperature(Id) = cold, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, cold), T).

initiatedAt(internal_temperature(Id) = very_cold, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, very_cold), T).

terminatedAt(internal_temperature(Id) = V, T) :-
    happensAt(internal_temperature_change(Id, _VehicleType, V2), T),
    V \= V2.

%--------------- noise_level -----------%

initially(noise_level(_, _)=low).

initiatedAt(noise_level(Id) = low, T) :-
    happensAt(noise_level_change(Id, _VehicleType, low), T).

initiatedAt(noise_level(Id) = normal, T) :-
    happensAt(noise_level_change(Id, _VehicleType, normal), T).

initiatedAt(noise_level(Id) = high, T) :-
    happensAt(noise_level_change(Id, _VehicleType, high), T).

terminatedAt(noise_level(Id) = V, T) :-
    happensAt(noise_level_change(Id, _VehicleType, V2), T),
    V \= V2.

%--------------- passenger_density -----------%

initially(passenger_density(_, _)=low).

initiatedAt(passenger_density(Id) = low, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, low), T).

initiatedAt(passenger_density(Id) = normal, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, normal), T).

initiatedAt(passenger_density(Id) = high, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, high), T).

terminatedAt(passenger_density(Id) = V, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, V2), T),
    V \= V2.

%--------------- punctuality -----------%

initially(punctuality(_, _)=punctual).

punct_status(early,     punctual).
punct_status(scheduled, punctual).
punct_status(late,      non_punctual).

initiatedAt(punctuality(Id) = Val, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, Status), T),
    punct_status(Status, Val).

initiatedAt(punctuality(Id) = non_punctual, T) :-
    happensAt(stop_leave(Id, _VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id) = V, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, Status), T),
    punct_status(Status, V2),
    V \= V2.

terminatedAt(punctuality(Id) = punctual, T) :-
    happensAt(stop_leave(Id, _VehicleType, _StopCode, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id) = unsafe, IUnsafe) :-
    holdsFor(sharp_turn(Id, _VehicleType) = very_sharp,      Ivst),
    holdsFor(abrupt_acceleration(Id, _VehicleType) = very_abrupt, Ivaa),
    holdsFor(abrupt_deceleration(Id, _VehicleType) = very_abrupt, Ivdd),
    union_all([Ivst, Ivaa, Ivdd], IUnsafe).

holdsFor(driving_style(Id) = uncomfortable, I) :-
    holdsFor(sharp_turn(Id, _VehicleType) = sharp,                IsSharp),
    holdsFor(abrupt_acceleration(Id, _VehicleType) = very_abrupt, IvaA),
    holdsFor(abrupt_deceleration(Id, _VehicleType) = very_abrupt, IvaD),
    union_all([IvaA, IvaD], IHighAgg),
    relative_complement_all(IsSharp, [IHighAgg], ITurnOnly),
    holdsFor(abrupt_acceleration(Id, _VehicleType) = abrupt,      IaA),
    holdsFor(abrupt_deceleration(Id, _VehicleType) = abrupt,      IaD),
    union_all([IaA, IaD], IAbr),
    union_all([ITurnOnly, IAbr], ICand),
    holdsFor(driving_style(Id) = unsafe, IUnsafe),
    relative_complement_all(ICand, [IUnsafe], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id) = high, IHigh) :-
    holdsFor(punctuality(Id) = punctual, IPunc),
    holdsFor(driving_style(Id) = unsafe, IUnsafe),
    holdsFor(driving_style(Id) = uncomfortable, IUncomf),
    union_all([IUnsafe, IUncomf], IBadStyle),
    relative_complement_all(IPunc, [IBadStyle], IHigh).

holdsFor(driving_quality(Id) = medium, IMed) :-
    holdsFor(punctuality(Id) = punctual, IPunc),
    holdsFor(driving_style(Id) = uncomfortable, IUncomf),
    intersect_all([IPunc, IUncomf], IMed).

holdsFor(driving_quality(Id) = low, ILow) :-
    holdsFor(punctuality(Id) = non_punctual, INonP),
    holdsFor(driving_style(Id) = unsafe,      IUnsafe),
    union_all([INonP, IUnsafe], ILow).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id) = reducing, I) :-
    holdsFor(driving_style(Id) = unsafe,         IUnsafe),
    holdsFor(driving_style(Id) = uncomfortable,  IUncomf),
    holdsFor(passenger_density(Id) = high,       IDensHigh),
    holdsFor(noise_level(Id) = high,             INoiseHigh),
    holdsFor(internal_temperature(Id) = very_warm, ITempWarm),
    holdsFor(internal_temperature(Id) = very_cold, ITempCold),
    union_all([ITempWarm, ITempCold], ITempBad),
    union_all([IUnsafe, IUncomf, IDensHigh, INoiseHigh, ITempBad], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id) = reducing, I) :-
    holdsFor(driving_style(Id) = unsafe,           IUnsafe),
    holdsFor(driving_style(Id) = uncomfortable,    IUncomf),
    holdsFor(noise_level(Id) = high,               INoiseHigh),
    holdsFor(internal_temperature(Id) = very_warm, ITempWarm),
    holdsFor(internal_temperature(Id) = very_cold, ITempCold),
    union_all([ITempWarm, ITempCold], ITempBad),
    union_all([IUnsafe, IUncomf, INoiseHigh, ITempBad], I).

%----------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id) = reducing, I) :-
    holdsFor(punctuality(Id) = non_punctual, INonP),
    holdsFor(passenger_comfort(Id) = reducing, IComfortRed),
    union_all([INonP, IComfortRed], I).

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
grounding(punctuality(Id)=punctual):-
    vehicle(Id).   
grounding(punctuality(Id)=non_punctual):-
    vehicle(Id).
grounding(punctuality(Id)=Val):-
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