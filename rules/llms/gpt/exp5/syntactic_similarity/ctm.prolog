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

terminatedAt(internal_temperature(Id, VehicleType)=Prev, T) :-
    happensAt(internal_temperature_change(Id, VehicleType, New), T),
    Prev \= New.

%--------------- noise_level -----------%

initiatedAt(noise_level(Id, VehicleType)=low, T) :-
    happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType)=normal, T) :-
    happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType)=high, T) :-
    happensAt(noise_level_change(Id, VehicleType, high), T).

terminatedAt(noise_level(Id, VehicleType)=Prev, T) :-
    happensAt(noise_level_change(Id, VehicleType, New), T),
    Prev \= New.

%--------------- passenger_density -----------%

initiatedAt(passenger_density(Id, VehicleType)=low, T) :-
    happensAt(passenger_density_change(Id, VehicleType, low), T).

initiatedAt(passenger_density(Id, VehicleType)=normal, T) :-
    happensAt(passenger_density_change(Id, VehicleType, normal), T).

initiatedAt(passenger_density(Id, VehicleType)=high, T) :-
    happensAt(passenger_density_change(Id, VehicleType, high), T).

terminatedAt(passenger_density(Id, VehicleType)=Prev, T) :-
    happensAt(passenger_density_change(Id, VehicleType, New), T),
    Prev \= New.

%--------------- punctuality -----------%

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

terminatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, early), T).
	
terminatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, scheduled), T).

terminatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _StopCode, late), T).
	
terminatedAt(punctuality(Id, VehicleType)=punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _StopCode, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType)=unsafe, Iu) :-
    holdsFor(sharp_turn(Id, VehicleType)=very_sharp, Ivst),
    holdsFor(abrupt_acceleration(Id, VehicleType)=very_abrupt, Ivaa),
    holdsFor(abrupt_deceleration(Id, VehicleType)=very_abrupt, Ivad),
    union_all([Ivst, Ivaa, Ivad], Iu).
	
holdsFor(driving_style(Id, VehicleType)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType)=sharp, Isharp),
    holdsFor(abrupt_acceleration(Id, VehicleType)=abrupt, Ia),
    holdsFor(abrupt_deceleration(Id, VehicleType)=abrupt, Id),
    union_all([Isharp, Ia, Id], I0),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    relative_complement_all(I0, [Iu], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    union_all([Iu, Iuc], Ibad),
    relative_complement_all(Ip, [Ibad], I).

holdsFor(driving_quality(Id, VehicleType)=medium, I) :-
    holdsFor(punctuality(Id, VehicleType)=punctual, Ip),
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    intersect_all([Ip, Iuc], Im0),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    relative_complement_all(Im0, [Iu], I).

holdsFor(driving_quality(Id, VehicleType)=low, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inp),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    union_all([Inp, Iu], I).
	
%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    holdsFor(passenger_density(Id, VehicleType)=high, Ipden),
    holdsFor(noise_level(Id, VehicleType)=high, Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, It_hot),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, It_cold),
    union_all([Iuc, Iu, Ipden, Inoise, It_hot, It_cold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType)=reducing, I) :-
    holdsFor(driving_style(Id, VehicleType)=uncomfortable, Iuc),
    holdsFor(driving_style(Id, VehicleType)=unsafe, Iu),
    holdsFor(noise_level(Id, VehicleType)=high, Inoise),
    holdsFor(internal_temperature(Id, VehicleType)=very_warm, It_hot),
    holdsFor(internal_temperature(Id, VehicleType)=very_cold, It_cold),
    union_all([Iuc, Iu, Inoise, It_hot, It_cold], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, I) :-
    holdsFor(punctuality(Id, VehicleType)=non_punctual, Inp),
    holdsFor(passenger_comfort(Id, VehicleType)=reducing, Ic),
    union_all([Inp, Ic], I).