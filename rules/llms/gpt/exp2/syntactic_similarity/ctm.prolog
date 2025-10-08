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

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(non_punctual(Id, VehicleType)=true, Inp),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, Icomf),
    union_all([Inp, Icomf], I).