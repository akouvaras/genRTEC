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

terminatedAt(internal_temperature(Id, VehicleType)=_Prev, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, _New), T).

%--------------- noise_level -----------%

initially(noise_level(_, _)=low).

initiatedAt(noise_level(Id, VehicleType)=low, T) :-
    happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType)=normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType)=high, T) :-
    happensAt(noise_level_change(Id, VehicleType, high), T).

terminatedAt(noise_level(Id, VehicleType)=_Prev, T) :-
    happensAt(noise_level_change(Id, VehicleType, _New), T).

%--------------- passenger_density -----------%

initially(passenger_density(_, _)=low).

initiatedAt(passenger_density(Id, VehicleType)=low, T) :-
    happensAt(passenger_density_change(Id, VehicleType, low), T).

initiatedAt(passenger_density(Id, VehicleType)=normal, T) :-
    happensAt(passenger_density_change(Id, VehicleType, normal), T).

initiatedAt(passenger_density(Id, VehicleType)=high, T) :-
    happensAt(passenger_density_change(Id, VehicleType, high), T).

terminatedAt(passenger_density(Id, VehicleType)=_Prev, T) :-
    happensAt(passenger_density_change(Id, VehicleType, _New), T).

%--------------- punctuality -----------%

initially(punctuality(_, _)=punctual).

initiatedAt(punctuality(Id, VehicleType, StopCode)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType, StopCode)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType, StopCode)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType, StopCode)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType, StopCode)=_Prev, T) :-
    happensAt(stop_enter(Id, VehicleType, StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType, StopCode)=_Prev, T) :-
    happensAt(stop_enter(Id, VehicleType, StopCode, scheduled), T).

terminatedAt(punctuality(Id, VehicleType, StopCode)=_Prev, T) :-
    happensAt(stop_enter(Id, VehicleType, StopCode, late), T).

terminatedAt(punctuality(Id, VehicleType, StopCode)=_Prev, T) :-
    happensAt(stop_leave(Id, VehicleType, StopCode, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id,VehicleType)=unsafe, I) :-
    holdsFor(sharp_turn(Id,VehicleType)=very_sharp, IvSharp),
    holdsFor(abrupt_acceleration(Id,VehicleType)=very_abrupt, IvAccel),
    holdsFor(abrupt_deceleration(Id,VehicleType)=very_abrupt, IvDecel),
    union_all([IvSharp, IvAccel, IvDecel], I).

holdsFor(driving_style(Id,VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id,VehicleType)=sharp, Isharp),
    holdsFor(abrupt_acceleration(Id,VehicleType)=abrupt, IaccAbr),
    holdsFor(abrupt_deceleration(Id,VehicleType)=abrupt, IdecAbr),
    holdsFor(abrupt_acceleration(Id,VehicleType)=very_abrupt, IaccVery),
    holdsFor(abrupt_deceleration(Id,VehicleType)=very_abrupt, IdecVery),
    relative_complement_all(Isharp, [IaccVery, IdecVery], IsharpOnly),
    union_all([IsharpOnly, IaccAbr, IdecAbr], Iu0),
    holdsFor(driving_style(Id,VehicleType)=unsafe, Iunsafe),
    relative_complement_all(Iu0, [Iunsafe], I).

%-------------- driving_quality ----------------%

holdsFor(punctual(Id, VehicleType)=true, I) :-
    findall(Ip,
        holdsFor(punctuality(Id, VehicleType, _StopCode)=punctual, Ip),
        Lp),
    union_all(Lp, I).

holdsFor(non_punctual(Id, VehicleType)=true, I) :-
    findall(Inp,
        holdsFor(punctuality(Id, VehicleType, _StopCode)=non_punctual, Inp),
        Ln),
    union_all(Ln, I).

holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctual(Id, VehicleType)=true, Ip),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    union_all([Iunsafe, Iunc], Ibad),
    relative_complement_all(Ip, [Ibad], I).

holdsFor(driving_quality(Id, VehicleType)=medium, I) :-
    holdsFor(punctual(Id, VehicleType)=true, Ip),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    intersect_all([Ip, Iunc], I).

holdsFor(driving_quality(Id, VehicleType)=low, I) :-
    holdsFor(non_punctual(Id, VehicleType)=true, Inp),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    union_all([Inp, Iunsafe], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    holdsFor(passenger_density(Id, VehicleType)=high, Idense),
    holdsFor(noise_level(Id, VehicleType)=high, Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Ihot),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, Icold),
    union_all([Iunsafe, Iunc, Idense, Inoise, Ihot, Icold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    holdsFor(noise_level(Id, VehicleType)=high, Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Ihot),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, Icold),
    union_all([Iunsafe, Iunc, Inoise, Ihot, Icold], I).

%----------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(non_punctual(Id, VehicleType)=true, Inp),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, Icomf),
    union_all([Inp, Icomf], I).

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
grounding(punctuality(Id,VehicleType,StopCode)=punctual):-
    vehicle(Id, VehicleType).   
grounding(punctuality(Id,VehicleType,StopCode)=non_punctual):-
    vehicle(Id, VehicleType).
grounding(punctuality(Id,VehicleType,StopCode)=_Prev):-
    vehicle(Id, VehicleType).
grounding(passenger_density(Id,VehicleType)=high):-
    vehicle(Id, VehicleType).
grounding(passenger_density(Id,VehicleType)=_Prev):-
    vehicle(Id, VehicleType).
grounding(noise_level(Id,VehicleType)=high):-
    vehicle(Id, VehicleType).
grounding(noise_level(Id,VehicleType)=_Prev):-
    vehicle(Id, VehicleType).
grounding(internal_temperature(Id,VehicleType)=very_warm):-
    vehicle(Id, VehicleType).
grounding(internal_temperature(Id,VehicleType)=very_cold):-
    vehicle(Id, VehicleType).
grounding(internal_temperature(Id,VehicleType)=_Prev):-
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