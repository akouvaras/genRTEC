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

initiatedAt(gap(Vessel)=nearPort, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, AreaType)=true, T),
    areaType(_, AreaType),
    member(AreaType, [port, anchorage]).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    \+ (holdsAt(withinArea(Vessel, AreaType)=true, T),
         areaType(_, AreaType),
         member(AreaType, [port, anchorage])).

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
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, coastal)=true, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(highSpeedNearCoast(Vessel)=true, T),  
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, coastal),
    holdsAt(highSpeedNearCoast(Vessel)=true, T).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=_Status1, I_stop),
    holdsFor(withinArea(Vessel, anchorage)=true, I_anchorage),
    intersect_all([I_stop, I_anchorage], I_case1),
    holdsFor(stopped(Vessel)=nearPorts, I_case2),
    union_all([I_case1, I_case2], I_temp), I_temp \= [],
    thresholds(aOrMTime, AOrMTime),
    intDurGreater(I_temp, AOrMTime, I).


%---------------- tugging (B) ----------------%

initiatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasTuggingSpeed(Vessel)=true, T),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasTuggingSpeed(Vessel)=true, T),
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
    intersect_all([Ip, I1, I2], I_temp), I_temp \= [],
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(I_temp, TuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, fishing)=true, T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasTrawlingSpeed(Vessel)=true, T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    Speed < TrawlingspeedMin.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasTrawlingSpeed(Vessel)=true, T),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed > TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, fishing).

%--------------- trawling --------------------%

initiatedAt(movementCharacteristicOfTrawling(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(movementCharacteristicOfTrawling(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, fishing).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(hasTrawlingSpeed(Vessel)=true, I1),
    holdsFor(movementCharacteristicOfTrawling(Vessel)=true, I2),
    intersect_all([I1, I2], I_temp), I_temp \= [],
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(I_temp, TrawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

initiatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasSARSpeed(Vessel)=true, T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(movementCharacteristicOfSAR(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(movementCharacteristicOfSAR(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(movementCharacteristicOfSAR(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(hasSARSpeed(Vessel)=true, I1),
    holdsFor(movementCharacteristicOfSAR(Vessel)=true, I2),
    intersect_all([I1, I2], I_temp), I_temp \= [],
    thresholds(sarTime, SarTime),
    intDurGreater(I_temp, SarTime, I).


%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    union_all([Il, Is], I_motion),
    holdsFor(withinArea(Vessel, coastal)=true, I_coast),
    relative_complement_all(I_motion, [I_coast], I_not_coast), I_not_coast \= [],
    holdsFor(anchoredOrMoored(Vessel)=true, I_anchored),
    relative_complement_all(I_not_coast, [I_anchored], I_candidate), I_candidate \= [],
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I_candidate, LoiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    union_all([Il1, Is1], I1_combined),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il2, Is2], I2_combined),
    intersect_all([I1_combined, I2_combined, Ip], I_motion), I_motion \= [],
    holdsFor(withinArea(Vessel1, coastal)=true, Ic1),
    holdsFor(withinArea(Vessel2, coastal)=true, Ic2),
    relative_complement_all(I_motion, [Ic1, Ic2], I).

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
grounding(movementCharacteristicOfSAR(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(movementCharacteristicOfSAR(Vessel)=false):-
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
grounding(movementCharacteristicOfTrawling(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(movementCharacteristicOfTrawling(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawling(Vessel)=true):-
	vessel(Vessel).
grounding(loitering(Vessel)=true):-
	vessel(Vessel).

needsGrounding(_, _, _) :-
	fail.
buildFromPoints(_) :-
	fail.


