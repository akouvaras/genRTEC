%--------------- internal_temperature -----------%

initiatedAt(internal_temperature(Id, VehicleType)=Value, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, Value), T).

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=Value, T) :-
    happensAt(noise_level_change(Id, VehicleType, Value), T).

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=Value, T) :-
    happensAt(passenger_density_change(Id, VehicleType, Value), T).

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType)=non-punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType)=non-punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp, ISharp),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, IAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, IDecel),
    union_all([ISharp, IAccel, IDecel], I).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp, ISharp),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, IVeryAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, IVeryDecel),
    relative_complement_all(ISharp, [IVeryAccel, IVeryDecel], IClauseA),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, IAbruptAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, IAbruptDecel),
    union_all([IAbruptAccel, IAbruptDecel], IClauseB),
    union_all([IClauseA, IClauseB], I).

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
    holdsFor(punctuality(Id, VehicleType)=non-punctual, INonPunctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, IUnsafe),
    union_all([INonPunctual, IUnsafe], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, IUncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, IUnsafe),
    holdsFor(passenger_density(Id, VehicleType)=high, IDensity),
    holdsFor(noise_level(Id, VehicleType)=high, INoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, IWarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, ICold),
    union_all([IUncomfortable, IUnsafe, IDensity, INoise, IWarm, ICold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, IUncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, IUnsafe),
    holdsFor(noise_level(Id, VehicleType)=high, INoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, IWarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, ICold),
    union_all([IUncomfortable, IUnsafe, INoise, IWarm, ICold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non-punctual, INonPunctual),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, IComfortReducing),
    union_all([INonPunctual, IComfortReducing], I).