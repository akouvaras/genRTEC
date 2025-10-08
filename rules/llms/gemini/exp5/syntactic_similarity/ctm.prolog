%--------------- internal_temperature -----------%

initiatedAt(internal_temperature(Id, VehicleType)=Value, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, Value), T).

terminatedAt(internal_temperature(Id, VehicleType)=OldValue, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, NewValue), T),
    OldValue \== NewValue,
    holdsAt(internal_temperature(Id, VehicleType)=OldValue, T).

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=Value, T) :-
    happensAt(noise_level_change(Id, VehicleType, Value), T).

terminatedAt(noise_level(Id, VehicleType)=OldValue, T) :-
    happensAt(noise_level_change(Id, VehicleType, NewValue), T),
    OldValue \== NewValue,
    holdsAt(noise_level(Id, VehicleType)=OldValue, T).

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=Value, T) :-
    happensAt(passenger_density_change(Id, VehicleType, Value), T).

terminatedAt(passenger_density(Id, VehicleType)=OldValue, T) :-
    happensAt(passenger_density_change(Id, VehicleType, NewValue), T),
    OldValue \== NewValue,
    holdsAt(passenger_density(Id, VehicleType)=OldValue, T).

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType)=OldValue, T) :-
    initiatedAt(punctuality(Id, VehicleType)=NewValue, T),
    OldValue \== NewValue.

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