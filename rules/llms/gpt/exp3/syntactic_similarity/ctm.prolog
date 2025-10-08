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

terminatedAt(internal_temperature(Id, VehicleType)=_Prev, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, _New), T).

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=low, T) :-
    happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType)=normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType)=high, T) :-
    happensAt(noise_level_change(Id, VehicleType, high), T).

terminatedAt(noise_level(Id, VehicleType)=_Prev, T) :-
    happensAt(noise_level_change(Id, VehicleType, _New), T).

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=low, T) :-
    happensAt(passenger_density_change(Id, VehicleType, low), T).

initiatedAt(passenger_density(Id, VehicleType)=normal, T) :-
    happensAt(passenger_density_change(Id, VehicleType, normal), T).

initiatedAt(passenger_density(Id, VehicleType)=high, T) :-
    happensAt(passenger_density_change(Id, VehicleType, high), T).

terminatedAt(passenger_density(Id, VehicleType)=_Prev, T) :-
    happensAt(passenger_density_change(Id, VehicleType, _New), T).

%--------------- punctuality -----------%

initiatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_leave(Id, _VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, late), T).

terminatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_leave(Id, _VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_enter(Id, _VehicleType, _StopCode, scheduled), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id)=unsafe, I) :-
    holdsFor(sharp_turn(Id, _VehicleType)=very_sharp,      Ivturn),
    holdsFor(abrupt_acceleration(Id, _VehicleType)=very_abrupt, Ivacc),
    holdsFor(abrupt_deceleration(Id, _VehicleType)=very_abrupt, Ivdec),
    union_all([Ivturn, Ivacc, Ivdec], I).

holdsFor(driving_style(Id)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, _VehicleType)=sharp,            Isharp),
    holdsFor(abrupt_acceleration(Id, _VehicleType)=very_abrupt, Ivacc_very),
    holdsFor(abrupt_deceleration(Id, _VehicleType)=very_abrupt, Ivdec_very),
    holdsFor(abrupt_acceleration(Id, _VehicleType)=abrupt,       Iacc_abrupt),
    holdsFor(abrupt_deceleration(Id, _VehicleType)=abrupt,       Idec_abrupt),
    relative_complement_all(Isharp, [Ivacc_very, Ivdec_very], Ia),
    union_all([Iacc_abrupt, Idec_abrupt], Ib),
    union_all([Ia, Ib], Icand),
    holdsFor(driving_style(Id)=unsafe, Iunsafe),
    relative_complement_all(Icand, [Iunsafe], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id)=high, I) :-
    holdsFor(punctuality(Id)=punctual, Ip),
    holdsFor(driving_style(Id)=unsafe, Iunsafe),
    holdsFor(driving_style(Id)=uncomfortable, Iuncomfy),
    relative_complement_all(Ip, [Iunsafe, Iuncomfy], I).

holdsFor(driving_quality(Id)=medium, I) :-
    holdsFor(punctuality(Id)=punctual, Ip),
    holdsFor(driving_style(Id)=uncomfortable, Iuncomfy),
    intersect_all([Ip, Iuncomfy], I).

holdsFor(driving_quality(Id)=low, I) :-
    holdsFor(punctuality(Id)=non_punctual, Inp),
    holdsFor(driving_style(Id)=unsafe, Iunsafe),
    union_all([Inp, Iunsafe], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id)=reducing, I) :-
    holdsFor(driving_style(Id)=unsafe, Iu1),
    holdsFor(driving_style(Id)=uncomfortable, Iu2),
    holdsFor(passenger_density(Id, _VehType)=high, Idens),
    holdsFor(noise_level(Id, _VehType)=high, Inoise),
    holdsFor(internal_temperature(Id, _VehType)=very_warm, It_hot),
    holdsFor(internal_temperature(Id, _VehType)=very_cold, It_cold),
    union_all([Iu1, Iu2, Idens, Inoise, It_hot, It_cold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id)=reducing, I) :-
    holdsFor(driving_style(Id)=unsafe, Iu1),
    holdsFor(driving_style(Id)=uncomfortable, Iu2),
    holdsFor(noise_level(Id, _VehType)=high, Inoise),
    holdsFor(internal_temperature(Id, _VehType)=very_warm, It_hot),
    holdsFor(internal_temperature(Id, _VehType)=very_cold, It_cold),
    union_all([Iu1, Iu2, Inoise, It_hot, It_cold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id)=reducing, I) :-
    holdsFor(punctuality(Id)=non_punctual, Inp),
    holdsFor(passenger_comfort(Id)=reducing, Ipc),
    union_all([Inp, Ipc], I).