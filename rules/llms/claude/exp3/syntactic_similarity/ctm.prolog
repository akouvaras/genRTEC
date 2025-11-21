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

holdsFor(driving_style(Id, VehicleType)=unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp, Iturn),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, Iacc),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, Idec),
    union_all([Iturn, Iacc, Idec], I).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp, Isharp),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, Ivery_acc),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, Ivery_dec),
    relative_complement_all(Isharp, [Ivery_acc, Ivery_dec], Isharp_only),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, Iacc),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, Idec),
    union_all([Isharp_only, Iacc, Idec], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ipunctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuncomfortable),
    relative_complement_all(Ipunctual, [Iunsafe, Iuncomfortable], I).

holdsFor(driving_quality(Id, VehicleType)=medium, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ipunctual),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    relative_complement_all(Iuncomfortable, [Iunsafe], Iuncomfortable_only),
    intersect_all([Ipunctual, Iuncomfortable_only], I).

holdsFor(driving_quality(Id, VehicleType)=low, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inon_punctual),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    union_all([Inon_punctual, Iunsafe], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    holdsFor(passenger_density(Id, VehicleType)=high, Idensity),
    holdsFor(noise_level(Id, VehicleType)=high, Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Ivery_warm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, Ivery_cold),
    union_all([Iuncomfortable, Iunsafe, Idensity, Inoise, Ivery_warm, Ivery_cold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuncomfortable),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    holdsFor(noise_level(Id, VehicleType)=high, Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Ivery_warm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, Ivery_cold),
    union_all([Iuncomfortable, Iunsafe, Inoise, Ivery_warm, Ivery_cold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inon_punctual),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, Icomfort),
    union_all([Inon_punctual, Icomfort], I).