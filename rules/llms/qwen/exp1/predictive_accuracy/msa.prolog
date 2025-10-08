%----------------within area -----------------%

initiatedAt(withinArea(Vessel, AreaType)=true, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, AreaType).

terminatedAt(withinArea(Vessel, AreaType)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, AreaType).

terminatedAt(withinArea(Vessel, _AreaType)=true, T) :-
    happensAt(gap_start(Vessel), T).

%-------------- stopped-----------------------%

initiatedAt(stopped(Vessel)=nearPorts, T) :-
    happensAt(stop_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(stopped(Vessel)=farFromPorts, T) :-
    happensAt(stop_start(Vessel), T),
    \+holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(stopped(Vessel)=_Status, T) :-
    happensAt(stop_end(Vessel), T).

terminatedAt(stopped(Vessel)=_Status, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

%--------------- communication gap -----------%
	
initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    \+ holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=_PortStatus, T) :-
    happensAt(gap_end(Vessel), T).


%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel), T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel), T) :-
    happensAt(start(gap(Vessel)=_Status), T).


%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, nearCoast),
    velocity(Vessel, Speed, _, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    velocity(Vessel, Speed, _, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel), T) :-
    happensAt(slow_motion_start(Vessel), T),
    velocity(Vessel, Speed, _, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel), T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, nearCoast).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=_Status, I_stop),
    holdsFor(withinArea(Vessel, nearPorts)=true, I_near),
    intersect_all([I_stop, I_near], I_moor),
    holdsFor(withinArea(Vessel, anchorage)=true, I_anch_area),
    holdsFor(withinArea(Vessel, nearPorts)=true, I_near_ports),
    relative_complement_all(I_stop, [I_near_ports], I_far_from_ports), 
    intersect_all([I_stop, I_anch_area, I_far_from_ports], I_anch),
    union_all([I_moor, I_anch], I_combined),
    thresholds(aOrMTime, AOrMTime),
    intDurGreater(I_combined, AOrMTime, I).

%---------------- tugging (B) ----------------%

initiatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(hasTuggingSpeed(Vessel), T) :-
    happensAt(change_in_speed_end(Vessel), T),
    holdsAt(hasTuggingSpeed(Vessel)=true, T),
    velocity(Vessel, Speed, _, T),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin.

terminatedAt(hasTuggingSpeed(Vessel), T) :-
    happensAt(change_in_speed_end(Vessel), T),
    holdsAt(hasTuggingSpeed(Vessel)=true, T),
    velocity(Vessel, Speed, _, T),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(hasTuggingSpeed(Vessel), T) :-
    happensAt(start(gap(Vessel)=_Status), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    oneIsTug(Vessel1, Vessel2),
    \+ oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(hasTuggingSpeed(Vessel1)=true, I1),
    holdsFor(hasTuggingSpeed(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], Ii),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(Ii, TuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, fishing),
    velocity(Vessel, Speed, _, T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax.

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T),
    velocity(Vessel, Speed, _, T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel), T) :-
    happensAt(change_in_speed_end(Vessel), T),
    holdsAt(hasTrawlingSpeed(Vessel)=true, T),
    velocity(Vessel, Speed, _, T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    Speed < TrawlingspeedMin.

terminatedAt(hasTrawlingSpeed(Vessel), T) :-
    happensAt(change_in_speed_end(Vessel), T),
    holdsAt(hasTrawlingSpeed(Vessel)=true, T),
    velocity(Vessel, Speed, _, T),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed > TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel), T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, fishing).

terminatedAt(hasTrawlingSpeed(Vessel), T) :-
    happensAt(start(gap(Vessel)=_Status), T).

%--------------- trawling --------------------%

initiatedAt(hasTrawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T),
    \+ holdsAt(hasTrawlingMovement(Vessel)=true, T).

terminatedAt(hasTrawlingMovement(Vessel), T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, fishing).

terminatedAt(hasTrawlingMovement(Vessel), T) :-
    happensAt(start(gap(Vessel)=_Status), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(hasTrawlingSpeed(Vessel)=true, I1),
    holdsFor(hasTrawlingMovement(Vessel)=true, I2),
    intersect_all([I1, I2], Ii),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(Ii, TrawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(hasSARSpeed(Vessel), T) :-
    happensAt(change_in_speed_end(Vessel), T),
    holdsAt(hasSARSpeed(Vessel)=true, T),
    velocity(Vessel, Speed, _, T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(hasSARSpeed(Vessel), T) :-
    happensAt(start(gap(Vessel)=_Status), T).

initiatedAt(hasSARMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    \+ holdsAt(hasSARMovement(Vessel)=true, T).

initiatedAt(hasSARMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    \+ holdsAt(hasSARMovement(Vessel)=true, T).

terminatedAt(hasSARMovement(Vessel), T) :-
    happensAt(start(gap(Vessel)=_Status), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(hasSARSpeed(Vessel)=true, I1),
    holdsFor(hasSARMovement(Vessel)=true, I2),
    intersect_all([I1, I2], Ii),
    thresholds(sarTime, SarTime),
    intDurGreater(Ii, SarTime, I).


%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    union_all([Il, Is], Imob),  
    holdsFor(withinArea(Vessel, nearCoast)=true, I_coastal),
    relative_complement_all(Imob, [I_coastal], I_non_coastal),  
    holdsFor(anchoredOrMoored(Vessel)=true, I_aorm),
    relative_complement_all(I_non_coastal, [I_aorm], I_clean),   
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I_clean, LoiteringTime, I).



%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    union_all([Il1, Is1], Ibeh1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il2, Is2], Ibeh2),
    intersect_all([Ibeh1, Ibeh2], Ibeh),
    holdsFor(withinArea(Vessel1, nearCoast)=true, Ic1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Ic2),
    union_all([Ic1, Ic2], I_coastal),  
    relative_complement_all(Ip, [I_coastal], I_non_coastal_prox),
    intersect_all([I_non_coastal_prox, Ibeh], I).

% proximity is an input statically determined fluent.
% its instances arrive in the form of intervals.
collectIntervals(proximity(_,_)=true).

% The elements of these domains are derived from the ground arguments of input entitites
dynamicDomain(vessel(_Vessel)).
dynamicDomain(vpair(_Vessel1,_Vessel2)).

% Groundings of input entities
grounding(change_in_speed_start(V)):- vessel(V).
grounding(change_in_speed_end(V)):- vessel(V).
grounding(change_in_heading(V)):- vessel(V).
grounding(stop_start(V)):- vessel(V).
grounding(stop_end(V)):- vessel(V).
grounding(slow_motion_start(V)):- vessel(V).
grounding(slow_motion_end(V)):- vessel(V).
grounding(gap_start(V)):- vessel(V).
grounding(gap_end(V)):- vessel(V).
grounding(entersArea(V,Area)):- vessel(V), areaType(Area).
grounding(leavesArea(V,Area)):- vessel(V), areaType(Area).
grounding(coord(V,_,_)):- vessel(V).
grounding(velocity(V,_,_,_)):- vessel(V).
grounding(proximity(Vessel1, Vessel2)=true):- vpair(Vessel1, Vessel2).

% Groundings of output entities
grounding(gap(Vessel)=PortStatus):-
	vessel(Vessel), portStatus(PortStatus).
grounding(stopped(Vessel)=PortStatus):-
	vessel(Vessel), portStatus(PortStatus).
grounding(lowSpeed(Vessel)=true):-
	vessel(Vessel).
grounding(changingSpeed(Vessel)=true):-
	vessel(Vessel).
grounding(withinArea(Vessel, AreaType)=true):-
	vessel(Vessel), areaType(AreaType).
grounding(underWay(Vessel)=true):-
	vessel(Vessel).
grounding(hasSARSpeed(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(hasSARMovement(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(hasSARMovement(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(inSAR(Vessel)=true):-
	vessel(Vessel).
grounding(highSpeedNearCoast(Vessel)=true):-
	vessel(Vessel).
grounding(anchoredOrMoored(Vessel)=true):-
	vessel(Vessel).
grounding(hasTrawlingSpeed(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(movingSpeed(Vessel)=Status):-
	vessel(Vessel), movingStatus(Status).
grounding(pilotOps(Vessel1, Vessel2)=true):-
	vpair(Vessel1, Vessel2).
grounding(tuggingSpeed(Vessel)=true):-
	vessel(Vessel).
grounding(tugging(Vessel1, Vessel2)=true):-
	vpair(Vessel1, Vessel2).
grounding(hasTrawlingMovement(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawlingMovement(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawling(Vessel)=true):-
	vessel(Vessel).
grounding(loitering(Vessel)=true):-
	vessel(Vessel).

needsGrounding(_, _, _) :-
	fail.
buildFromPoints(_) :-
	fail.


