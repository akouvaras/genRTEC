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

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    velocity(Vessel, Speed, _, _),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, nearCoast).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=nearPorts, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    holdsFor(withinArea(Vessel, anchorage)=true, I3),
    intersect_all([I2, I3], I4),
    union_all([I1, I4], Iu),
    thresholds(aOrMTime, AOrMTime),
    intDurGreater(Iu, AOrMTime, I).

%---------------- tugging (B) ----------------%

initiatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

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
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax,
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    Speed < TrawlingspeedMin.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed > TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, fishing).

%--------------- trawling --------------------%

holdsFor(movementIsTrawling(Vessel)=true, I) :-
    holdsFor(withinArea(Vessel, fishing)=true, I).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(hasTrawlingSpeed(Vessel)=true, I1),
    holdsFor(movementIsTrawling(Vessel)=true, I2),
    intersect_all([I1, I2], Ii),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(Ii, TrawlingTime, I).

%-------------------------- SAR --------------%
	
initiatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(movementIsSAR(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(movementIsSAR(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(movementIsSAR(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(hasSARSpeed(Vessel)=true, I1),
    holdsFor(movementIsSAR(Vessel)=true, I2),
    intersect_all([I1, I2], Ii),
    thresholds(sarTime, SarTime),
    intDurGreater(Ii, SarTime, I).


%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    union_all([Il, Is], IMotion),
    holdsFor(withinArea(Vessel, nearCoast)=true, ICoast),
    relative_complement_all(IMotion, [ICoast], INonCoast),
    holdsFor(anchoredOrMoored(Vessel)=true, IAnchored),
    relative_complement_all(INonCoast, [IAnchored], IPure),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(IPure, LoiteringTime, I).


%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    union_all([Il1, Is1], I1_lowMotion),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il2, Is2], I2_lowMotion),
    holdsFor(withinArea(Vessel1, nearCoast)=true, Ic1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Ic2),
    relative_complement_all(Ip, [Ic1, Ic2], InonCoast),
    intersect_all([Ip, InonCoast, I1_lowMotion, I2_lowMotion], Ii),
    I = Ii.

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
grounding(movementIsSAR(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(movementIsSAR(Vessel)=false):-
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
grounding(hasTuggingSpeed(Vessel)=true):-
	vessel(Vessel).
grounding(tugging(Vessel1, Vessel2)=true):-
	vpair(Vessel1, Vessel2).
grounding(movementIsTrawling(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(movementIsTrawling(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawling(Vessel)=true):-
	vessel(Vessel).
grounding(loitering(Vessel)=true):-
	vessel(Vessel).

needsGrounding(_, _, _) :-
	fail.
buildFromPoints(_) :-
	fail.


