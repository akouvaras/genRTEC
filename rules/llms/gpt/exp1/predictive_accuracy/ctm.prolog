%--------------- internal_temperature -----------%

initially(internal_temperature(_)=normal).

initiatedAt(internal_temperature(Id)=very_warm,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, very_warm), T). 

initiatedAt(internal_temperature(Id)=warm,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, warm), T). 

initiatedAt(internal_temperature(Id)=normal,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, normal), T). 

initiatedAt(internal_temperature(Id)=cold,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, cold), T). 

initiatedAt(internal_temperature(Id)=very_cold,T) :-
	happensAt(internal_temperature_change(Id,VehicleType, very_cold), T). 

%--------------- noise_level -----------%

initially(noise_level(_)=low).


initiatedAt(noise_level(Id)=low, T) :-
	happensAt(noise_level_change(Id, VehicleType, low), T).

initiatedAt(noise_level(Id)=normal, T) :-
	happensAt(noise_level_change(Id, VehicleType, normal), T).

initiatedAt(noise_level(Id)=high, T) :-
	happensAt(noise_level_change(Id, VehicleType, high), T).

%--------------- passenger_density -----------%

initially(passenger_density(_)=low).

initiatedAt(passenger_density(Id)=low, T) :-
	happensAt(passenger_density_change(Id, VehicleType, low), T). 

initiatedAt(passenger_density(Id)=normal, T) :-
	happensAt(passenger_density_change(Id, VehicleType, normal), T). 

initiatedAt(passenger_density(Id)=high, T) :-
	happensAt(passenger_density_change(Id, VehicleType, high), T). 

%--------------- punctuality -----------%

initiatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_enter(Id, _Type, _StopCode, early), T).

initiatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_enter(Id, _Type, _StopCode, scheduled), T).

initiatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_enter(Id, _Type, _StopCode, late), T).

initiatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_leave(Id, _Type, _StopCode, early), T).

terminatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_enter(Id, _Type, _StopCode, late), T).
	
terminatedAt(punctuality(Id)=punctual, T) :-
    happensAt(stop_leave(Id, _Type, _StopCode, early), T).

terminatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_enter(Id, _Type, _StopCode, early), T).
	
terminatedAt(punctuality(Id)=non_punctual, T) :-
    happensAt(stop_enter(Id, _Type, _StopCode, scheduled), T).

%-------------- driving_style----------------------%

holdsFor(driving_style(Id)=unsafe, I) :-
    holdsFor(sharp_turn(Id, _Type)=very_sharp, It_vs),
    holdsFor(abrupt_acceleration(Id, _Type)=very_abrupt, Ia_va),
    holdsFor(abrupt_deceleration(Id, _Type)=very_abrupt, Id_vd),
    union_all([It_vs, Ia_va, Id_vd], I).

holdsFor(driving_style(Id)=uncomfortable, I) :-
    holdsFor(sharp_turn(Id, _Type)=very_sharp, It_vs),
    holdsFor(abrupt_acceleration(Id, _Type)=very_abrupt, Ia_va),
    holdsFor(abrupt_deceleration(Id, _Type)=very_abrupt, Id_vd),
    union_all([It_vs, Ia_va, Id_vd], I_unsafe),
    holdsFor(sharp_turn(Id, _Type)=sharp, It_s),
    relative_complement_all(It_s, [I_unsafe], I_turn_only),
    holdsFor(abrupt_acceleration(Id, _Type)=abrupt, Ia_a),
    holdsFor(abrupt_deceleration(Id, _Type)=abrupt, Id_a),
    union_all([Ia_a, Id_a], I_abrupt),
    relative_complement_all(I_abrupt, [I_unsafe], I_abrupt_only),
    union_all([I_turn_only, I_abrupt_only], I).

%-------------- driving_quality ----------------%

holdsFor(driving_quality(Id)=high, I) :-
    holdsFor(punctuality(Id)=punctual, Ip),
    holdsFor(driving_style(Id)=unsafe, Iu),
    holdsFor(driving_style(Id)=uncomfortable, Iuc),
    union_all([Iu, Iuc], Ibad),
    relative_complement_all(Ip, [Ibad], I).

holdsFor(driving_quality(Id)=medium, I) :-
    holdsFor(punctuality(Id)=punctual, Ip),
    holdsFor(driving_style(Id)=uncomfortable, Iuc),
    intersect_all([Ip, Iuc], Ipu),
    holdsFor(driving_style(Id)=unsafe, Iu),
    relative_complement_all(Ipu, [Iu], I).

holdsFor(driving_quality(Id)=low, I) :-
    holdsFor(punctuality(Id)=non_punctual, Inp),
    holdsFor(driving_style(Id)=unsafe, Iu),
    union_all([Inp, Iu], I).

%------------ passenger_comfort -------------%

holdsFor(passenger_comfort(Id)=reducing, I) :-
    holdsFor(driving_style(Id)=uncomfortable, Ids_uc),
    holdsFor(driving_style(Id)=unsafe,        Ids_u),
    holdsFor(passenger_density(Id)=high,      Ipdh),
    holdsFor(noise_level(Id)=high,            Inh),
    holdsFor(internal_temperature(Id)=very_warm, It_vw),
    holdsFor(internal_temperature(Id)=very_cold, It_vc),
    union_all([Ids_uc, Ids_u, Ipdh, Inh, It_vw, It_vc], I).

%--------------- driver_comfort -----------------%

holdsFor(driver_comfort(Id)=reducing, I) :-
    holdsFor(driving_style(Id)=uncomfortable, Ids_uc),
    holdsFor(driving_style(Id)=unsafe,        Ids_u),
    holdsFor(noise_level(Id)=high,            Inh),
    holdsFor(internal_temperature(Id)=very_warm, It_vw),
    holdsFor(internal_temperature(Id)=very_cold, It_vc),
    union_all([Ids_uc, Ids_u, Inh, It_vw, It_vc], I).

%---------------- passenger_satisfaction ------------------%

holdsFor(passenger_satisfaction(Id)=reducing, I) :-
    holdsFor(punctuality(Id)=non_punctual, Inp),
    holdsFor(passenger_comfort(Id)=reducing, Ic),
    union_all([Inp, Ic], I).
	
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
grounding(punctuality(Id)=punctual)            :- vehicle(Id, _).
grounding(punctuality(Id)=non_punctual)        :- vehicle(Id, _).
grounding(passenger_density(Id)=high)          :- vehicle(Id, _).
grounding(noise_level(Id)=high)                :- vehicle(Id, _).
grounding(internal_temperature(Id)=very_warm)  :- vehicle(Id, _).
grounding(internal_temperature(Id)=very_cold)  :- vehicle(Id, _).
grounding(driving_style(Id)=unsafe)            :- vehicle(Id, _).
grounding(driving_style(Id)=uncomfortable)     :- vehicle(Id, _).
grounding(driving_quality(Id)=high)            :- vehicle(Id, _).
grounding(driving_quality(Id)=medium)          :- vehicle(Id, _).
grounding(driving_quality(Id)=low)             :- vehicle(Id, _).
grounding(passenger_comfort(Id)=reducing)      :- vehicle(Id, _).
grounding(driver_comfort(Id)=reducing)         :- vehicle(Id, _).
grounding(passenger_satisfaction(Id)=reducing) :- vehicle(Id, _).