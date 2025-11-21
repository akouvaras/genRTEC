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

initiatedAt(punctuality(Id, VehicleType, StopCode)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType, StopCode)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType, StopCode)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType, StopCode)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, StopCode, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, I) :-
    holdsFor(sharp_turn(Id,VehicleType)=very_sharp,         Ivst),
    holdsFor(abrupt_acceleration(Id,VehicleType)=very_abrupt, Ivaa),
    holdsFor(abrupt_deceleration(Id,VehicleType)=very_abrupt, Ivad),
    union_all([Ivst, Ivaa, Ivad], I).

holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id,VehicleType)=sharp,              Ist),
    holdsFor(abrupt_acceleration(Id,VehicleType)=abrupt,    Iaa),
    holdsFor(abrupt_deceleration(Id,VehicleType)=abrupt,    Iad),
    union_all([Ist, Iaa, Iad], Ipre),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iunsafe),
    relative_complement_all(Ipre, [Iunsafe], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType, StopCode)=high, I) :-
    holdsFor(punctuality(Id, VehicleType, StopCode)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=unsafe,        Iu),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    relative_complement_all(Ip, [Iu, Iuc], I).
	
holdsFor(driving_quality(Id, VehicleType, StopCode)=medium, I) :-
    holdsFor(punctuality(Id, VehicleType, StopCode)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    holdsFor(driving_style(Id, VehicleType)=unsafe,        Iu),
    intersect_all([Ip, Iuc], Im),
    relative_complement_all(Im, [Iu], I).
	
holdsFor(driving_quality(Id, VehicleType, StopCode)=low, I) :-
    holdsFor(punctuality(Id, VehicleType, StopCode)=non_punctual, Inp),
    holdsFor(driving_style(Id, VehicleType)=unsafe,               Iu),
    % low if either non-punctual OR unsafe
    union_all([Inp, Iu], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=unsafe,         Iu),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable,  Iuc),
    holdsFor(passenger_density(Id, VehicleType)=high,       Idens),
    holdsFor(noise_level(Id, VehicleType)=high,             Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Itwarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, Itcold),
    union_all([Iu, Iuc, Idens, Inoise, Itwarm, Itcold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=unsafe,         Iu),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable,  Iuc),
    holdsFor(noise_level(Id, VehicleType)=high,             Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, Itwarm),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, Itcold),
    union_all([Iu, Iuc, Inoise, Itwarm, Itcold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType, StopCode)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType, StopCode)=non_punctual, Inp),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, Ic),
    union_all([Inp, Ic], I).