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

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=low, T) :-
    happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType)=normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType)=high, T) :-
    happensAt(noise_level_change(Id, VehicleType, high), T).

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=low, T) :-
    happensAt(passenger_density_change(Id, VehicleType, low), T).

initiatedAt(passenger_density(Id, VehicleType)=normal, T) :-
    happensAt(passenger_density_change(Id, VehicleType, normal), T).

initiatedAt(passenger_density(Id, VehicleType)=high, T) :-
    happensAt(passenger_density_change(Id, VehicleType, high), T).

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, Iu) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp,      Ivst),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, Ivaa),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, Ivad),
    union_all([Ivst, Ivaa, Ivad], Iu).

holdsFor(driving_style_base_uncomfortable(Id, VehicleType)=true, Iu0) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp,            Isharp),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, Ivaa),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, Ivad),
    relative_complement_all(Isharp, [Ivaa, Ivad], Iturn_only),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt,  Iaa),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt,  Iad),
    union_all([Iturn_only, Iaa, Iad], Iu0).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(driving_style_base_uncomfortable(Id, VehicleType)=true, Iu0),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    relative_complement_all(Iu0, [Iu], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=low, Ilow) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inp),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    union_all([Inp, Iu], Ilow).

holdsFor(driving_quality(Id, VehicleType)=medium, Imed) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    intersect_all([Ip, Iunc], Imed0), Imed0 \= [],
    holdsFor(driving_quality(Id, VehicleType)=low, Ilow),
    relative_complement_all(Imed0, [Ilow], Imed).

holdsFor(driving_quality(Id, VehicleType)=high, Ihigh) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    union_all([Iu, Iunc], IbadStyle),
    relative_complement_all(Ip, [IbadStyle], Ihigh).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    holdsFor(driving_style(Id, VehicleType)=unsafe,        Iuns),
    union_all([Iunc, Iuns], Ids),
    holdsFor(passenger_density(Id, VehicleType)=high, Ipd),
    holdsFor(noise_level(Id, VehicleType)=high,       Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Itvw),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, Itvc),
    union_all([Itvw, Itvc], Itemp),
    union_all([Ids, Ipd, Inoise, Itemp], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iunc),
    holdsFor(driving_style(Id, VehicleType)=unsafe,        Iuns),
    union_all([Iunc, Iuns], Ids),
    holdsFor(noise_level(Id, VehicleType)=high,       Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Itvw),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, Itvc),
    union_all([Itvw, Itvc], Itemp),
    union_all([Ids, Inoise, Itemp], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inp),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, Ipc),
    union_all([Inp, Ipc], I).