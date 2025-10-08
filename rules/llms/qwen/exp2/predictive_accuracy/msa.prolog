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

holdsFor(highSpeedNearCoast(Vessel)=true, I) :-
    holdsFor(withinArea(Vessel, nearCoast)=true, I1),
    holdsFor(excessiveSpeed(Vessel)=true, I2),
    intersect_all([I1, I2], I).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=_Status1, I1),
    holdsFor(withinArea(Vessel, nearPorts)=true, I2),
    intersect_all([I1, I2], I_nearPort),
    holdsFor(stopped(Vessel)=_Status2, I3),
    holdsFor(withinArea(Vessel, anchorage)=true, I4),
    holdsFor(withinArea(Vessel, nearPorts)=true, I5),
    relative_complement_all(I3, [I5], I_farFromPorts),  
    intersect_all([I3, I4, I_farFromPorts], I_inAnchorage),  
    union_all([I_nearPort, I_inAnchorage], I_unfiltered),
    thresholds(aOrMTime, AOrMTime),
    intDurGreater(I_unfiltered, AOrMTime, I).

%---------------- tugging (B) ----------------%

initiatedAt(withinTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.
	
terminatedAt(withinTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(tuggingMin, TuggingMin), 
	Speed < TuggingMin.

terminatedAt(withinTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(tuggingMax, TuggingMax), 
	Speed > TuggingMax.

terminatedAt(withinTuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    Vessel1 @< Vessel2,
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    oneIsTug(Vessel1, Vessel2),
    \+ oneIsPilot(Vessel1, Vessel2),
    holdsFor(withinTuggingSpeed(Vessel1)=true, I1),
    holdsFor(withinTuggingSpeed(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], I_candidate),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(I_candidate, TuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax.

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, fishing),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(trawlingspeedMin, TrawlingspeedMin), 
	Speed < TrawlingspeedMin.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(trawlingspeedMax, TrawlingspeedMax), 
	Speed > TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, fishing).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(characteristicTrawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(characteristicTrawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, fishing).

terminatedAt(characteristicTrawlingMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(hasTrawlingSpeed(Vessel)=true, I1),
    holdsFor(characteristicTrawlingMovement(Vessel)=true, I2),
    intersect_all([I1, I2], I_unfiltered),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(I_unfiltered, TrawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(exhibitingSARMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    holdsAt(sarSpeed(Vessel)=true, T).

initiatedAt(exhibitingSARMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(sarSpeed(Vessel)=true, T).
	
terminatedAt(exhibitingSARMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sarSpeed(Vessel)=true, I1),
    holdsFor(exhibitingSARMovement(Vessel)=true, I2),
    intersect_all([I1, I2], I_candidate),
    thresholds(sarTime, SarTime),
    intDurGreater(I_candidate, SarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    union_all([Il, Is], I_movement),
    holdsFor(withinArea(Vessel, nearCoast)=true, I_coast),
    relative_complement_all(I_movement, [I_coast], I_offCoast),
    I_offCoast \= [],
    holdsFor(anchoredOrMoored(Vessel)=true, I_aorm),
    relative_complement_all(I_offCoast, [I_aorm], I_unfiltered),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I_unfiltered, LoiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    Vessel1 @< Vessel2,
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    union_all([Il1, Is1], I_behave1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il2, Is2], I_behave2),
    holdsFor(withinArea(Vessel1, nearPorts)=true, Iw1),
    holdsFor(withinArea(Vessel2, nearPorts)=true, Iw2),
    holdsFor(withinArea(Vessel1, nearCoast)=true, Ic1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Ic2),
    relative_complement_all(Ip, [Iw1, Iw2, Ic1, Ic2], I_noGo),
    I_noGo \= [],  
    intersect_all([I_noGo, I_behave1, I_behave2], I_unfiltered),
    I = I_unfiltered.

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
grounding(sarSpeed(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(exhibitingSARMovement(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(exhibitingSARMovement(Vessel)=false):-
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
grounding(withinTuggingSpeed(Vessel)=true):-
	vessel(Vessel).
grounding(tugging(Vessel1, Vessel2)=true):-
	vpair(Vessel1, Vessel2).
grounding(characteristicTrawlingMovement(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(characteristicTrawlingMovement(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawling(Vessel)=true):-
	vessel(Vessel).
grounding(loitering(Vessel)=true):-
	vessel(Vessel).

needsGrounding(_, _, _) :-
	fail.
buildFromPoints(_) :-
	fail.


