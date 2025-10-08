%--------------- internal_temperature -----------%

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

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id) = reducing, I) :-
    holdsFor(punctuality(Id) = non_punctual, INonP),
    holdsFor(passenger_comfort(Id) = reducing, IComfortRed),
    union_all([INonP, IComfortRed], I).