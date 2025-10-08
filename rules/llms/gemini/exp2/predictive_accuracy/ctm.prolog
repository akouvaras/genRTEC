%--------------- internal_temperature -----------%

initially(internal_temperature(_, _)=normal).

initiatedAt(internal_temperature(Id, VehicleType)=very_warm,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, very_warm), T). 

initiatedAt(internal_temperature(Id, VehicleType)=warm,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, warm), T). 

initiatedAt(internal_temperature(Id, VehicleType)=normal,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, normal), T). 

initiatedAt(internal_temperature(Id, VehicleType)=cold,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, cold), T). 

initiatedAt(internal_temperature(Id, VehicleType)=very_cold,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, very_cold), T). 

%--------------- noise_level -----------%

initially(noise_level(_, _)=low).


initiatedAt(noise_level(Id, VehicleType)=low, T) :-
	happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id, VehicleType)=normal, T) :-
	happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id, VehicleType)=high, T) :-
	happensAt(noise_level_change(Id, VehicleType, high), T).

%--------------- passenger_density -----------%

initially(passenger_density(_, _)=low).

initiatedAt(passenger_density(Id, VehicleType)=low, T) :-
	happensAt(passenger_density_change(Id, VehicleType, low), T). 

initiatedAt(passenger_density(Id, VehicleType)=normal, T) :-
	happensAt(passenger_density_change(Id, VehicleType, normal), T). 

initiatedAt(passenger_density(Id, VehicleType)=high, T) :-
	happensAt(passenger_density_change(Id, VehicleType, high), T). 

%--------------- punctuality -----------%

initially(punctuality(_, _)=punctual).

initiatedAt(punctuality(Id, VehicleType) = punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, early), T).

initiatedAt(punctuality(Id, VehicleType) = punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, scheduled), T).

initiatedAt(punctuality(Id, VehicleType) = non_punctual, T) :-
    happensAt(stop_enter(Id, VehicleType, _, late), T).

initiatedAt(punctuality(Id, VehicleType) = non_punctual, T) :-
    happensAt(stop_leave(Id, VehicleType, _, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id, VehicleType) = unsafe, I) :-
    holdsFor(sharp_turn(Id, VehicleType) = very_sharp, I_Turn),
    holdsFor(abrupt_acceleration(Id, VehicleType) = very_abrupt, I_Accel),
    holdsFor(abrupt_deceleration(Id, VehicleType) = very_abrupt, I_Decel),
    union_all([I_Turn, I_Accel, I_Decel], I).

holdsFor(driving_style(Id, VehicleType) = uncomfortable, I) :-
    holdsFor(sharp_turn(Id, VehicleType) = sharp, I_SharpTurn),
    holdsFor(abrupt_acceleration(Id, VehicleType) = very_abrupt, I_VAbruptAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType) = very_abrupt, I_VAbruptDecel),
    relative_complement_all(I_SharpTurn, [I_VAbruptAccel, I_VAbruptDecel], I_A),
    holdsFor(abrupt_acceleration(Id, VehicleType) = abrupt, I_AbruptAccel),
    holdsFor(abrupt_deceleration(Id, VehicleType) = abrupt, I_AbruptDecel),
    union_all([I_AbruptAccel, I_AbruptDecel], I_B),
    union_all([I_A, I_B], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType) = high, I) :-
    holdsFor(punctuality(Id, VehicleType) = punctual, I_Punctual),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I_Unsafe),
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I_Uncomfortable),
    relative_complement_all(I_Punctual, [I_Unsafe, I_Uncomfortable], I).

holdsFor(driving_quality(Id, VehicleType) = medium, I) :-
    holdsFor(punctuality(Id, VehicleType) = punctual, I_Punctual),
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I_Uncomfortable),
    intersect_all([I_Punctual, I_Uncomfortable], I).

holdsFor(driving_quality(Id, VehicleType) = low, I) :-
    holdsFor(punctuality(Id, VehicleType) = non_punctual, I_NonPunctual),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I_Unsafe),
    union_all([I_NonPunctual, I_Unsafe], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id, VehicleType) = reducing, I) :-
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I_Uncomfortable),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I_Unsafe),
    holdsFor(passenger_density(Id, VehicleType) = high, I_Density),
    holdsFor(noise_level(Id, VehicleType) = high, I_Noise),
    holdsFor(internal_temperature(Id, VehicleType) = very_warm, I_VWarm),
    holdsFor(internal_temperature(Id, VehicleType) = very_cold, I_VCold),
    union_all([I_Uncomfortable, I_Unsafe, I_Density, I_Noise, I_VWarm, I_VCold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id, VehicleType) = reducing, I) :-
    holdsFor(driving_style(Id, VehicleType) = uncomfortable, I_Uncomfortable),
    holdsFor(driving_style(Id, VehicleType) = unsafe, I_Unsafe),
    holdsFor(noise_level(Id, VehicleType) = high, I_Noise),
    holdsFor(internal_temperature(Id, VehicleType) = very_warm, I_VWarm),
    holdsFor(internal_temperature(Id, VehicleType) = very_cold, I_VCold),
    union_all([I_Uncomfortable, I_Unsafe, I_Noise, I_VWarm, I_VCold], I).

%----------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType) = reducing, I) :-
    holdsFor(punctuality(Id, VehicleType) = non_punctual, I_NonPunctual),
    holdsFor(passenger_comfort(Id, VehicleType) = reducing, I_Comfort),
    union_all([I_NonPunctual, I_Comfort], I).

% These input statically determined fluents arrive in the form of intervals in input streams.
collectIntervals(abrupt_acceleration(_,_)=abrupt).
collectIntervals(abrupt_acceleration(_,_)=very_abrupt).
collectIntervals(abrupt_deceleration(_,_)=abrupt).
collectIntervals(abrupt_deceleration(_,_)=very_abrupt).
collectIntervals(sharp_turn(_,_)=sharp).
collectIntervals(sharp_turn(_,_)=very_sharp).

% The elements of these domains are derived from the ground arguments of input entitites
dynamicDomain(vehicle(_,_)).

% Grounding for input entities:
grounding(stop_enter(Id, VehicleType,_,_)):-
    vehicle(Id, VehicleType).
grounding(stop_leave(Id, VehicleType,_,_)):-
    vehicle(Id, VehicleType).
grounding(internal_temperature_change(Id, VehicleType,_)):-
    vehicle(Id, VehicleType).
grounding(noise_level_change(Id, VehicleType,_)):-
    vehicle(Id, VehicleType).
grounding(passenger_density_change(Id, VehicleType,_)):-
    vehicle(Id, VehicleType).
grounding(punctuality_change(Id,VehicleType,punctual)):-
    vehicle(Id, VehicleType).
grounding(punctuality_change(Id,VehicleType,non_punctual)):-
    vehicle(Id, VehicleType).
grounding(abrupt_acceleration(Id,VehicleType)=abrupt):-
    vehicle(Id, VehicleType). 
grounding(abrupt_acceleration(Id,VehicleType)=very_abrupt):-
    vehicle(Id, VehicleType). 
grounding(abrupt_deceleration(Id,VehicleType)=abrupt):-
    vehicle(Id, VehicleType). 
grounding(abrupt_deceleration(Id,VehicleType)=very_abrupt):-
    vehicle(Id, VehicleType). 
grounding(sharp_turn(Id,VehicleType)=sharp):-
    vehicle(Id, VehicleType). 
grounding(sharp_turn(Id,VehicleType)=very_sharp):-
    vehicle(Id, VehicleType).

% Grounding for output entities:
grounding(punctuality(Id,VehicleType)=punctual):-
    vehicle(Id, VehicleType).   
grounding(punctuality(Id,VehicleType)=non_punctual):-
    vehicle(Id, VehicleType).
grounding(passenger_density(Id,VehicleType)=high):-
    vehicle(Id, VehicleType).
grounding(noise_level(Id,VehicleType)=high):-
    vehicle(Id, VehicleType).
grounding(internal_temperature(Id,VehicleType)=very_warm):-
    vehicle(Id, VehicleType).
grounding(internal_temperature(Id,VehicleType)=very_cold):-
    vehicle(Id, VehicleType).
grounding(driving_style(Id,VehicleType)=unsafe):-
    vehicle(Id, VehicleType).
grounding(driving_style(Id,VehicleType)=uncomfortable):-
    vehicle(Id, VehicleType).
grounding(driving_quality(Id,VehicleType)=high):-
    vehicle(Id, VehicleType).
grounding(driving_quality(Id,VehicleType)=medium):-
    vehicle(Id, VehicleType).
grounding(driving_quality(Id,VehicleType)=low):-
    vehicle(Id, VehicleType). 
grounding(passenger_comfort(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).
grounding(driver_comfort(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).
grounding(passenger_satisfaction(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).