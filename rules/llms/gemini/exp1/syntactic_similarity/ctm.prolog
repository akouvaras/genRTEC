%--------------- internal_temperature -----------%

initiatedAt(internal_temperature(Id, VehicleType)=Status, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, Status), T).

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=Status, T) :-
    happensAt(noise_level_change(Id, VehicleType, Status), T).

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=Status, T) :-
    happensAt(passenger_density_change(Id, VehicleType, Status), T).

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, Status), T),
    member(Status, [early, scheduled]).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp, ITurn),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, IAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, IDecel),
    union_all([ITurn, IAccel, IDecel], I).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp, ISharpTurn),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, IVeryAbruptAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, IVeryAbruptDecel),
    relative_complement_all(ISharpTurn, [IVeryAbruptAccel, IVeryAbruptDecel], IClauseA),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, IAbruptAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, IAbruptDecel),
    union_all([IAbruptAccel, IAbruptDecel], IClauseB),
    union_all([IClauseA, IClauseB], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, HQDI) :- 
	holdsFor(punctuality(Id, VehicleType)=punctual, PunctualI),
	holdsFor(driving_style(Id, VehicleType)=unsafe, USI),
	holdsFor(driving_style(Id, VehicleType)=uncomfortable, UCI),
	relative_complement_all(PunctualI, [USI, UCI], HQDI).

holdsFor(driving_quality(Id, VehicleType)=medium, MQDI) :- 
	holdsFor(punctuality(Id, VehicleType)=punctual, PunctualI),
	holdsFor(driving_style(Id, VehicleType)=uncomfortable, UCI), 
	intersect_all([PunctualI, UCI], MQDI).

holdsFor(driving_quality(Id, VehicleType)=low, LQDI) :- 
	holdsFor(punctuality(Id, VehicleType)=non_punctual, NPI),
	holdsFor(driving_style(Id, VehicleType)=unsafe, USI),  
	union_all([NPI, USI], LQDI).

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
    holdsFor(punctuality(Id, VehicleType)=non_punctual, IPunctuality),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, IComfort),
    union_all([IPunctuality, IComfort], I).