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
    happensAt(start(gap(Vessel)=_Status), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).


%-------------- anchoredOrMoored ---------------%

initiatedAt(stopped_simple(Vessel)=true, T) :-
    happensAt(stop_start(Vessel), T).

terminatedAt(stopped_simple(Vessel)=true, T) :-
    happensAt(stop_end(Vessel), T).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped_simple(Vessel)=true, I_Idle),
    holdsFor(withinArea(Vessel, nearPorts)=true, I_NearPort),
    holdsFor(withinArea(Vessel, anchorage)=true, I_Anchorage),
    intersect_all([I_Idle, I_NearPort], I_Term1),
    intersect_all([I_Idle, I_Anchorage], I_IdleAndAnchorage),
    relative_complement_all(I_IdleAndAnchorage, [I_NearPort], I_Term2),
    union_all([I_Term1, I_Term2], I_Combined),
    thresholds(aOrMTime, AOrMTime),
    intDurGreater(I_Combined, AOrMTime, I).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    oneIsTug(Vessel1, Vessel2),
    \+ oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, IProx),
    holdsFor(tuggingSpeed(Vessel1)=true, ISpeed1),
    holdsFor(tuggingSpeed(Vessel2)=true, ISpeed2),
    intersect_all([IProx, ISpeed1, ISpeed2], IIntersection),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(IIntersection, TuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax,
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed > TrawlingspeedMax.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    Speed < TrawlingspeedMin.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishing)=true), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishing)=true), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlingSpeed(Vessel)=true, ISpeed),
    holdsFor(trawlingMovement(Vessel)=true, IMovement),
    intersect_all([ISpeed, IMovement], IIntersection),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(IIntersection, TrawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sarSpeed(Vessel)=true, ISpeed),
    holdsFor(sarMovement(Vessel)=true, IMovement),
    intersect_all([ISpeed, IMovement], IIntersection),
    thresholds(sarTime, SarTime),
    intDurGreater(IIntersection, SarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I_LowSpeed),
    holdsFor(stopped(Vessel)=farFromPorts, I_Stopped),
    union_all([I_LowSpeed, I_Stopped], I_Movement),
    holdsFor(withinArea(Vessel, nearCoast)=true, I_Coast),
    holdsFor(anchoredOrMoored(Vessel)=true, I_Anchored),
    relative_complement_all(I_Movement, [I_Coast, I_Anchored], I_Filtered),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I_Filtered, LoiteringTime, I).


%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, I_Prox),
    holdsFor(lowSpeed(Vessel1)=true, I_LowSpeed1),
    holdsFor(lowSpeed(Vessel2)=true, I_LowSpeed2),
    holdsFor(stopped(Vessel1)=farFromPorts, I_Stopped1),
    holdsFor(stopped(Vessel2)=farFromPorts, I_Stopped2),
    union_all([I_LowSpeed1, I_Stopped1], I_Movement1),
    union_all([I_LowSpeed2, I_Stopped2], I_Movement2),
    intersect_all([I_Prox, I_Movement1, I_Movement2], I_Positive),
    holdsFor(withinArea(Vessel1, nearCoast)=true, I_Coast1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, I_Coast2),
    relative_complement_all(I_Positive, [I_Coast1, I_Coast2], I).
	
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
grounding(stopped_simple(Vessel)=true):-
	vessel(Vessel).
grounding(sarSpeed(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(sarMovement(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(sarMovement(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(inSAR(Vessel)=true):-
	vessel(Vessel).
grounding(highSpeedNearCoast(Vessel)=true):-
	vessel(Vessel).
grounding(anchoredOrMoored(Vessel)=true):-
	vessel(Vessel).
grounding(trawlingSpeed(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(movingSpeed(Vessel)=Status):-
	vessel(Vessel), movingStatus(Status).
grounding(pilotOps(Vessel1, Vessel2)=true):-
	vpair(Vessel1, Vessel2).
grounding(tuggingSpeed(Vessel)=true):-
	vessel(Vessel).
grounding(tugging(Vessel1, Vessel2)=true):-
	vpair(Vessel1, Vessel2).
grounding(trawlingMovement(Vessel)=true):-
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


