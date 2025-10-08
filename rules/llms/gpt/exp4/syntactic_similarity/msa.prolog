%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    not holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=_Status, T) :-
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

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(idle(Vessel)=true, Ii),
    holdsFor(withinArea(Vessel, anchorage)=true, Ia),
    holdsFor(withinArea(Vessel, nearPorts)=true, Ip),
    intersect_all([Ii, Ia], I_idle_in_anch),
    relative_complement_all(I_idle_in_anch, [Ip], I_caseA),
    intersect_all([Ii, Ip], I_caseB),
    union_all([I_caseA, I_caseB], I_candidates),
    intDurGreater(I_candidates, aOrMTime, I).

%--------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, Min),
    thresholds(tuggingMax, Max),
    Speed >= Min, 
    Speed =< Max.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, Min),
    thresholds(tuggingMax, Max),
    Speed < Min).

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, Min),
    thresholds(tuggingMax, Max),
    Speed > Max.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    oneIsTug(Vessel1, Vessel2),
    not oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(tuggingSpeed(Vessel1)=true, Is1),
    holdsFor(tuggingSpeed(Vessel2)=true, Is2),
    intersect_all([Ip, Is1, Is2], Ii), Ii \= [],
    intDurGreater(Ii, tuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, Min),
    thresholds(trawlingspeedMax, Max),
    Speed >= Min, Speed =< Max,
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, Min),
    thresholds(trawlingspeedMax, Max),
    Speed < Min.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, Min),
    thresholds(trawlingspeedMax, Max),
    Speed > Max.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlingSpeed(Vessel)=true, I_speed),
    holdsFor(trawlingMovement(Vessel)=true, I_move),
    intersect_all([I_speed, I_move], I_raw),
    intDurGreater(I_raw, trawlingTime, I).

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
    happensAt(start(gap(Vessel)=_GapStatus), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sarSpeed(Vessel)=true, I_speed),
    holdsFor(sarMovement(Vessel)=true, I_move),
    intersect_all([I_speed, I_move], I_raw),
    intDurGreater(I_raw, sarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Ils),
    holdsFor(stopped(Vessel)=farFromPorts, Isf),
    union_all([Ils, Isf], Imove),
    holdsFor(withinArea(Vessel, nearCoast)=true, Ic),
    holdsFor(anchoredOrMoored(Vessel)=true, Iaom),
    relative_complement_all(Imove, [Ic, Iaom], Iclean),
    intDurGreater(Iclean, loiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il1, Is1], I1b),
    union_all([Il2, Is2], I2b),
    intersect_all([Ip, I1b, I2b], If), If \= [],
    holdsFor(withinArea(Vessel1, nearCoast)=true, Ic1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Ic2),
    relative_complement_all(If, [Ic1, Ic2], I).