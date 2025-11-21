%--------------- internal_temperature -----------%

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

terminatedAt(internal_temperature(Id)=V1, T) :-
    initiatedAt(internal_temperature(Id)=V2, T),
    V1 \= V2.

%--------------- noise_level -----------%

initiatedAt(noise_level(Id)=low, T) :-
    happensAt(noise_level_change(Id, _VehicleType, low), T).

initiatedAt(noise_level(Id)=normal, T) :-
    happensAt(noise_level_change(Id, _VehicleType, normal), T).

initiatedAt(noise_level(Id)=high, T) :-
    happensAt(noise_level_change(Id, _VehicleType, high), T).

terminatedAt(noise_level(Id)=V1, T) :-
    initiatedAt(noise_level(Id)=V2, T),
    V1 \= V2.

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id)=low, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, low), T).

initiatedAt(passenger_density(Id)=normal, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, normal), T).

initiatedAt(passenger_density(Id)=high, T) :-
    happensAt(passenger_density_change(Id, _VehicleType, high), T).

terminatedAt(passenger_density(Id)=V1, T) :-
    initiatedAt(passenger_density(Id)=V2, T),
    V1 \= V2.

%--------------- punctuality -----------%

initiatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_leave(Id, _VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id)=V1, T) :-
    initiatedAt(punctuality(Id)=V2, T),
    V1 \= V2.

%-------------- driving_style----------------------%

holdsFor(driving_style(Id)=unsafe, I) :-
    holdsFor(sharp_turn(Id, _VehicleType)=very_sharp,         It_vs),
    holdsFor(abrupt_acceleration(Id, _VehicleType)=very_abrupt,It_va),
    holdsFor(abrupt_deceleration(Id, _VehicleType)=very_abrupt,It_vd),
    union_all([It_vs, It_va, It_vd], I).
	
holdsFor(driving_style(Id)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, _VehicleType)=sharp,                It_s),
    holdsFor(abrupt_acceleration(Id, _VehicleType)=abrupt,      It_aa),
    holdsFor(abrupt_deceleration(Id, _VehicleType)=abrupt,      It_ad),
    holdsFor(abrupt_acceleration(Id, _VehicleType)=very_abrupt, It_va),
    holdsFor(abrupt_deceleration(Id, _VehicleType)=very_abrupt, It_vd),
    holdsFor(driving_style(Id)=unsafe,                          Iunsafe),
    relative_complement_all(It_s, [It_va, It_vd],               It_sharp_ok),
    union_all([It_aa, It_ad],                                   It_abrupt),
    union_all([It_sharp_ok, It_abrupt],                         I0),
    relative_complement_all(I0, [Iunsafe],      

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id)=high, I) :-
    holdsFor(punctuality(Id)=punctual,            Ip),
    holdsFor(driving_style(Id)=unsafe,            Iu),
    holdsFor(driving_style(Id)=uncomfortable,     Iuc),
    relative_complement_all(Ip, [Iu, Iuc], I).

holdsFor(driving_quality(Id)=medium, I) :-
    holdsFor(punctuality(Id)=punctual,            Ip),
    holdsFor(driving_style(Id)=uncomfortable,     Iuc),
    intersect_all([Ip, Iuc], I).

holdsFor(driving_quality(Id)=low, I) :-
    holdsFor(punctuality(Id)=non_punctual,        Inp),
    holdsFor(driving_style(Id)=unsafe,            Iu),
    union_all([Inp, Iu], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id)=reducing, I) :-
    holdsFor(driving_style(Id)=unsafe,            Iu),
    holdsFor(driving_style(Id)=uncomfortable,     Iuc),
    holdsFor(passenger_density(Id)=high,          Ipden),
    holdsFor(noise_level(Id)=high,                Inoise),
    holdsFor(internal_temperature(Id)=very_warm,  It_hot),
    holdsFor(internal_temperature(Id)=very_cold,  It_cold),
    union_all([Iu, Iuc, Ipden, Inoise, It_hot, It_cold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id)=reducing, I) :-
    holdsFor(driving_style(Id)=unsafe,            Iu),
    holdsFor(driving_style(Id)=uncomfortable,     Iuc),
    holdsFor(noise_level(Id)=high,                Inoise),
    holdsFor(internal_temperature(Id)=very_warm,  It_hot),
    holdsFor(internal_temperature(Id)=very_cold,  It_cold),
    union_all([Iu, Iuc, Inoise, It_hot, It_cold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id)=reducing, I) :-
    holdsFor(punctuality(Id)=non_punctual,      Inp),
    holdsFor(passenger_comfort(Id)=reducing,    Ipc),
    union_all([Inp, Ipc], I).