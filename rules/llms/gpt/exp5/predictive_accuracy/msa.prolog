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
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).

%-------------- anchoredOrMoored ---------------%

holdsFor(aorm_far(Vessel)=true, Ifar) :-
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    holdsFor(withinArea(Vessel, anchorageArea)=true, Ia),
    intersect_all([Is, Ia], Ifar), Ifar \= [].

holdsFor(aorm_near(Vessel)=true, Inear) :-
    holdsFor(stopped(Vessel)=nearPorts, Inear).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(aorm_far(Vessel)=true, Ifar),
    holdsFor(aorm_near(Vessel)=true, Inear),
    union_all([Ifar, Inear], I).

%---------------- tugging (B) ----------------%
	
initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin.
	
terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.
	
terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).
	
holdsFor(tugging_base(Vessel1, Vessel2)=true, If) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    \+ oneIsPilot(Vessel1, Vessel2),
    oneIsTug(Vessel1, Vessel2),
    holdsFor(tuggingSpeed(Vessel1)=true, I1),
    holdsFor(tuggingSpeed(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], If), If \= [].

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(tugging_base(Vessel1, Vessel2)=true, I).

%---------------- trawlingSpeed -----------------%
	
initiatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin, 
	Speed =< TrawlingspeedMax,
    holdsAt(withinArea(Vessel, fishing)=true, T).
	
terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    Speed < TrawlingspeedMin.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed > TrawlingspeedMax.
	
terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishing)=true), T).

%--------------- trawling --------------------%

initiatedAt(trawlingPattern(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlingPattern(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishing)=true), T).

holdsFor(trawling_base(Vessel)=true, If) :-
    holdsFor(trawlingSpeed(Vessel)=true, Is),
    holdsFor(trawlingPattern(Vessel)=true, Ip),
    intersect_all([Is, Ip], If), If \= [].

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawling_base(Vessel)=true, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarPattern(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarPattern(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarPattern(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR_base(Vessel)=true, If) :-
    holdsFor(sarSpeed(Vessel)=true, Is),
    holdsFor(sarPattern(Vessel)=true, Ip),
    intersect_all([Is, Ip], If), If \= [].

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(inSAR_base(Vessel)=true, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    union_all([Il, Is], Im),                     
    holdsFor(withinArea(Vessel, nearCoast)=true, Icoast),
    holdsFor(anchoredOrMoored(Vessel)=true, Iaom),
    relative_complement_all(Im, [Icoast, Iaom], I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il1, Is1], I1b),
    union_all([Il2, Is2], I2b),
    intersect_all([I1b, I2b, Ip], If), If \= [],
    holdsFor(withinArea(Vessel1, nearCoast)=true, Iw1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Iw2),
    relative_complement_all(If, [Iw1, Iw2], I).

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
grounding(sarPattern(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(sarPattern(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,sar).
grounding(inSAR(Vessel)=true):-
	vessel(Vessel).
grounding(highSpeedNearCoast(Vessel)=true):-
	vessel(Vessel).
grounding(aorm_far(Vessel)=true):-
	vessel(Vessel).
grounding(aorm_near(Vessel)=true):-
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
grounding(tugging_base(Vessel1, Vessel2)=true):-
	vpair(Vessel1, Vessel2).
grounding(trawlingPattern(Vessel)=true):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawlingPattern(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,fishing).
grounding(trawling_base(Vessel)=false):-
	vessel(Vessel), vesselType(Vessel,fishing).	
grounding(trawling(Vessel)=true):-
	vessel(Vessel).
grounding(loitering(Vessel)=true):-
	vessel(Vessel).

needsGrounding(_, _, _) :-
	fail.
buildFromPoints(_) :-
	fail.


