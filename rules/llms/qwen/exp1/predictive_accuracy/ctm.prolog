%--------------- internal_temperature -----------%

initially(internal_temperature(_)=normal).

initiatedAt(internal_temperature(Id)=very_warm, T) :-
    happensAt(internal_temperature_change(Id, _, very_warm), T).

initiatedAt(internal_temperature(Id)=warm, T) :-
    happensAt(internal_temperature_change(Id, _, warm), T).

initiatedAt(internal_temperature(Id)=normal, T) :-
    happensAt(internal_temperature_change(Id, _, normal), T).

initiatedAt(internal_temperature(Id)=cold, T) :-
    happensAt(internal_temperature_change(Id, _, cold), T).

initiatedAt(internal_temperature(Id)=very_cold, T) :-
    happensAt(internal_temperature_change(Id, _, very_cold), T).

%--------------- noise_level -----------%

initially(noise_level(_)=low).


initiatedAt(noise_level(Id)=low, T) :-
    happensAt(noise_level_change(Id, _, low), T).

initiatedAt(noise_level(Id)=normal, T) :-
    happensAt(noise_level_change(Id, _, normal), T).

initiatedAt(noise_level(Id)=high, T) :-
    happensAt(noise_level_change(Id, _, high), T).

%--------------- passenger_density -----------%

initially(passenger_density(_)=low).

initiatedAt(passenger_density(Id)=low, T) :-
    happensAt(passenger_density_change(Id, _, low), T).

initiatedAt(passenger_density(Id)=normal, T) :-
    happensAt(passenger_density_change(Id, _, normal), T).

initiatedAt(passenger_density(Id)=high, T) :-
    happensAt(passenger_density_change(Id, _, high), T).

%--------------- punctuality -----------%

initially(punctuality(_, _)=punctual).

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
	happensAt(stop_enter(Id, VehicleType, StopCode, scheduled), T).	

initiatedAt(punctuality(Id, VehicleType)=punctual, T) :-
	happensAt(stop_enter(Id, VehicleType, StopCode, early), T).	

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
	happensAt(stop_enter(Id, VehicleType, StopCode, late), T).

initiatedAt(punctuality(Id, VehicleType)=non_punctual, T) :-
	happensAt(stop_leave(Id, VehicleType, StopCode, early), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id)=unsafe, I) :-
    holdsFor(sharp_turn(Id, _)=very_sharp, I1),
    holdsFor(abrupt_acceleration(Id, _)=very_abrupt, I2),
    holdsFor(abrupt_deceleration(Id, _)=very_abrupt, I3),
    union_all([I1, I2, I3], I).

holdsFor(driving_style(Id)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, _)=sharp, I_sharp),
    holdsFor(sharp_turn(Id, _)=very_sharp, I_very_sharp),
    relative_complement_all(I_sharp, [I_very_sharp], I_only_sharp),
    holdsFor(abrupt_acceleration(Id, _)=very_abrupt, I_aa_very),
    holdsFor(abrupt_deceleration(Id, _)=very_abrupt, I_ad_very),
    union_all([I_aa_very, I_ad_very], I_very_abrupt_motion),
    relative_complement_all(I_only_sharp, [I_very_abrupt_motion], I_case1),
    holdsFor(abrupt_acceleration(Id, _)=abrupt, I_aa_abrupt),
    holdsFor(abrupt_acceleration(Id, _)=very_abrupt, I_aa_very_abrupt),
    relative_complement_all(I_aa_abrupt, [I_aa_very_abrupt], I_aa_clean),
    holdsFor(abrupt_deceleration(Id, _)=abrupt, I_ad_abrupt),
    holdsFor(abrupt_deceleration(Id, _)=very_abrupt, I_ad_very_abrupt),
    relative_complement_all(I_ad_abrupt, [I_ad_very_abrupt], I_ad_clean),
    union_all([I_aa_clean, I_ad_clean], I_case2),
    union_all([I_case1, I_case2], I).


%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id, VehicleType)=high, HQDI) :- 
	holdsFor(punctuality(Id, VehicleType)=punctual, PunctualI),
	holdsFor(driving_style(Id, VehicleType)=unsafe, USI),
	holdsFor(driving_style(Id, VehicleType)=uncomfortable, UCI),
	relative_complement_all(PunctualI, [USI, UCI], HQDI).

holdsFor(driving_quality(Id, VehicleType)=medium, MQDI) :- 
	holdsFor(punctuality(Id, VehicleType)=punctual, PunctualI),
	holdsFor(driving_style(Id, VehicleType)=uncomfortable, UCI), 
	intersect_all([PunctualI, UCI], MQDI).

holdsFor(driving_quality(Id, VehicleType)=low, LQDI) :- 
	holdsFor(punctuality(Id, VehicleType)=non_punctual, NPI),
	holdsFor(driving_style(Id, VehicleType)=unsafe, USI),  
	union_all([NPI, USI], LQDI).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id)=reducing, I) :-
    holdsFor(driving_style(Id)=uncomfortable, I_uncomf),
    holdsFor(driving_style(Id)=unsafe, I_unsafe),
    holdsFor(passenger_density(Id)=high, I_dense),
    holdsFor(noise_level_change(Id, _)=high, I_noisy),
    holdsFor(internal_temperature(Id)=very_warm, I_hot),
    holdsFor(internal_temperature(Id)=very_cold, I_cold),
    union_all([I_uncomf, I_unsafe, I_dense, I_noisy, I_hot, I_cold], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id)=reducing, I) :-
    holdsFor(driving_style(Id)=unsafe, I_unsafe),	             
    holdsFor(driving_style(Id)=uncomfortable, I_uncomf),
    holdsFor(noise_level_change(Id, _)=high, I_noisy),
    holdsFor(internal_temperature(Id)=very_warm, I_hot),
    holdsFor(internal_temperature(Id)=very_cold, I_cold),
    union_all([I_unsafe, I_uncomf, I_noisy, I_hot, I_cold], I).

%----------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id, VehicleType)=reducing, RPSI) :-
	holdsFor(punctuality(Id, VehicleType)=non_punctual, NPI),
	holdsFor(passenger_comfort(Id, VehicleType)=reducing, RPCI),
	union_all([NPI, RPCI], RPSI).

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
grounding(passenger_density(Id)=high):-
    vehicle(Id, VehicleType).
grounding(noise_level(Id)=high):-
    vehicle(Id, VehicleType).
grounding(internal_temperature(Id)=very_warm):-
    vehicle(Id, VehicleType).
grounding(internal_temperature(Id)=very_cold):-
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
grounding(passenger_comfort(Id)=reducing):-
    vehicle(Id, VehicleType).
grounding(driver_comfort(Id)=reducing):-
    vehicle(Id, VehicleType).
grounding(passenger_satisfaction(Id,VehicleType)=reducing):-
    vehicle(Id, VehicleType).