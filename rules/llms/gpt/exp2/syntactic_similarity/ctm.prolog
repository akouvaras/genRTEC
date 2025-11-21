%--------------- internal_temperature -----------%

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

terminatedAt(internal_temperature(Id, VehicleType)=Old, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, New), T),
    Old \= New.

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=low, T) :-
    happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType)=normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType)=high, T) :-
    happensAt(noise_level_change(Id, VehicleType, high), T).

terminatedAt(noise_level(Id, VehicleType)=Old, T) :-
    happensAt(noise_level_change(Id, VehicleType, New), T),
    Old \= New.

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=low, T) :-
    happensAt(passenger_density_change(Id, VehicleType, low), T).

initiatedAt(passenger_density(Id, VehicleType)=normal, T) :-
    happensAt(passenger_density_change(Id, VehicleType, normal), T).

initiatedAt(passenger_density(Id, VehicleType)=high, T) :-
    happensAt(passenger_density_change(Id, VehicleType, high), T).

terminatedAt(passenger_density(Id, VehicleType)=Old, T) :-
    happensAt(passenger_density_change(Id, VehicleType, New), T),
    Old \= New.

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType)=_Old, T) :-
    happensAt(stop_enter(Id, VehicleType, _AnyStop, _AnyStatus), T).

terminatedAt(punctuality(Id, VehicleType)=_Old, T) :-
    happensAt(stop_leave(Id, VehicleType, _AnyStop, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp,           Ivs),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, Iava),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, Iavd),
    union_all([Ivs, Iava, Iavd], I).
	
holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp,                 Isharp),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt,  Iava),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt,  Iavd),
    union_all([Iava, Iavd], IveryAbr),
    relative_complement_all(Isharp, [IveryAbr], IA),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, Iaa),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, Iad),
    union_all([Iaa, Iad], IB),
    union_all([IA, IB], Iraw),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    relative_complement_all(Iraw, [Iunsafe], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=low, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inp),
    holdsFor(driving_style(Id, VehicleType)=unsafe,      Iu),
    union_all([Inp, Iu], I).
	
holdsFor(driving_quality(Id, VehicleType)=medium, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual,      Ip),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    intersect_all([Ip, Iunc], Im_raw),
    holdsFor(driving_quality(Id, VehicleType)=low, Ilow),
    relative_complement_all(Im_raw, [Ilow], I).
	
holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=unsafe,      Iu),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    union_all([Iu, Iunc], Ibad),
    relative_complement_all(Ip, [Ibad], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    holdsFor(driving_style(Id, VehicleType)=unsafe,        Iuns),
    holdsFor(passenger_density(Id, VehicleType)=high,      Idens),
    holdsFor(noise_level(Id, VehicleType)=high,            Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Iwarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold,  Icold),
    union_all([Iunc, Iuns, Idens, Inoise, Iwarm, Icold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    holdsFor(driving_style(Id, VehicleType)=unsafe,        Iuns),
    holdsFor(noise_level(Id, VehicleType)=high,            Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Iwarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold,  Icold),
    union_all([Iunc, Iuns, Inoise, Iwarm, Icold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual,         Inp),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing,       Icomfort),
    union_all([Inp, Icomfort], I).