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
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax,
    holdsAt(highSpeedNearCoast(Vessel)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, nearCoast).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=_Status, I_stop),
    holdsFor(withinArea(Vessel, nearPorts)=true, I_near),
    holdsFor(withinArea(Vessel, Type)=true, I_anc_temp),
    anchorageAreaType(Type),
    I_anc = I_anc_temp,
    union_all([I_near, I_anc], I_loc),
    intersect_all([I_stop, I_loc], I_candidate),
    I_candidate \= [],
    thresholds(aOrMTime, AOrMTime),
    intDurGreater(I_candidate, AOrMTime, I).

%---------------- tugging (B) ----------------%

initiatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax,
    \+ holdsAt(hasTuggingSpeed(Vessel)=true, T).

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin,
    holdsAt(hasTuggingSpeed(Vessel)=true, T).
	
terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax,
    holdsAt(hasTuggingSpeed(Vessel)=true, T).

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    oneIsTug(Vessel1, Vessel2),
    \+ oneIsPilot(Vessel1, Vessel2),
    holdsFor(hasTuggingSpeed(Vessel1)=true, I1),
    holdsFor(hasTuggingSpeed(Vessel2)=true, I2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    intersect_all([I1, I2, Ip], I_inter),
    I_inter \= [],  % non-empty intersection
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(I_inter, TuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax,
    holdsAt(withinFishingArea(Vessel)=true, T),
    \+ holdsAt(hasTrawlingSpeed(Vessel)=true, T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    Speed < TrawlingspeedMin,
    holdsAt(hasTrawlingSpeed(Vessel)=true, T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed > TrawlingspeedMax,
    holdsAt(hasTrawlingSpeed(Vessel)=true, T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, Type),
    fishingAreaType(Type).

%--------------- trawling --------------------%
	
initiatedAt(movementTrawling(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinFishingArea(Vessel)=true, T).

terminatedAt(movementTrawling(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, Type),
    fishingAreaType(Type).

terminatedAt(movementTrawling(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(hasTrawlingSpeed(Vessel)=true, I1),
    holdsFor(movementTrawling(Vessel)=true, I2),
    intersect_all([I1, I2], I_inter),
    I_inter \= [],  % non-empty
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(I_inter, TrawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed,
    \+ holdsAt(hasSARSpeed(Vessel)=true, T).

terminatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed,
    holdsAt(hasSARSpeed(Vessel)=true, T).

terminatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(movementSAR(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    \+ holdsAt(movementSAR(Vessel)=true, T).

initiatedAt(movementSAR(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    \+ holdsAt(movementSAR(Vessel)=true, T).

terminatedAt(movementSAR(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(hasSARSpeed(Vessel)=true, I1),
    holdsFor(movementSAR(Vessel)=true, I2),
    intersect_all([I1, I2], I_inter),
    I_inter \= [],  % non-empty overlap
    thresholds(sarTime, SarTime),
    intDurGreater(I_inter, SarTime, I).

%-------- loitering --------------------------%

holdsFor(inLoiterMotion(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    union_all([I1, I2], I).

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(inLoiterMotion(Vessel)=true, I_motion),
    holdsFor(withinArea(Vessel, nearCoast)=true, I_coast),
    relative_complement_all(I_motion, [I_coast], I_no_coast),
    holdsFor(anchoredOrMoored(Vessel)=true, I_orm),
    relative_complement_all(I_no_coast, [I_orm], I_candidate),
    I_candidate \= [],
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(I_candidate, LoiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(inLowMotion(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    union_all([I1, I2], I).

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(inLowMotion(Vessel1)=true, I1),
    holdsFor(inLowMotion(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], I_candidate),
    I_candidate \= [],  % non-empty
    holdsFor(withinArea(Vessel1, nearCoast)=true, Ic1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Ic2),
    relative_complement_all(I_candidate, [Ic1, Ic2], I).

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
grounding(movementSAR(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(movementSAR(Vessel)=false):-
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
grounding(movementTrawling(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(movementTrawling(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawling(Vessel)=true):-
	vessel(Vessel).
grounding(loitering(Vessel)=true):-
	vessel(Vessel).
grounding(inLoiterMotion(Vessel)=true):-
	vessel(Vessel).
grounding(inLowMotion(Vessel)=true):-
	vessel(Vessel).

needsGrounding(_, _, _) :-
	fail.
buildFromPoints(_) :-
	fail.


