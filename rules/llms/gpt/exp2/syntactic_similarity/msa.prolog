%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    not holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, noBaseStation),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, noBaseStation),
    not holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=_Status, T) :-
    happensAt(gap_end(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=nearPorts, Inp),
    holdsFor(stopped(Vessel)=farFromPorts, Ifp),
    holdsFor(withinArea(Vessel, anchorage)=true, Ia),
    intersect_all([Ifp, Ia], IfarAnch), IfarAnch \= [],
    union_all([Inp, IfarAnch], Iu), Iu \= [],
    intDurGreater(Iu, aOrMTime, I).

%--------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(tuggingMin, Min),
    thresholds(tuggingMax, Max),
    Speed >= Min,
    Speed =< Max.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(tuggingMin, Min),
    Speed < Min.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(tuggingMax, Max),
    Speed > Max.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(V1, V2)=true, I) :-
    oneIsTug(V1, V2),
    not oneIsPilot(V1, V2),
    holdsFor(proximity(V1, V2)=true, Ip),
    holdsFor(tuggingSpeed(V1)=true, I1),
    holdsFor(tuggingSpeed(V2)=true, I2),
    intersect_all([Ip, I1, I2], If), If \= [],
    intDurGreater(If, tuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(trawlingspeedMin, Tmin),
    thresholds(trawlingspeedMax, Tmax),
    Speed >= Tmin,
    Speed =< Tmax,
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(trawlingspeedMin, Tmin),
    Speed < Tmin.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(trawlingspeedMax, Tmax),
    Speed > Tmax.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishing)=true), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMotion(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlingMotion(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishing)=true), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlingSpeed(Vessel)=true, Is),
    holdsFor(trawlingMotion(Vessel)=true, Im),
    intersect_all([Is, Im], If), If \= [],
    intDurGreater(If, trawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TrueHeading), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMotion(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMotion(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMotion(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sarSpeed(Vessel)=true, Is),
    holdsFor(sarMotion(Vessel)=true, Im),
    intersect_all([Is, Im], If), If \= [],
    intDurGreater(If, sarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Ils),
    holdsFor(stopped(Vessel)=farFromPorts, Isf),
    union_all([Ils, Isf], Ib),
    holdsFor(withinArea(Vessel, nearCoast)=true, Icoast),
    holdsFor(anchoredOrMoored(Vessel)=true, Ianchor),
    relative_complement_all(Ib, [Icoast, Ianchor], Ii),
    intDurGreater(Ii, loiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(V1, V2)=true, I) :-
    oneIsPilot(V1, V2),
    holdsFor(proximity(V1, V2)=true, Ip),
    holdsFor(lowSpeed(V1)=true, Il1),
    holdsFor(lowSpeed(V2)=true, Il2),
    holdsFor(stopped(V1)=farFromPorts, Is1),
    holdsFor(stopped(V2)=farFromPorts, Is2),
    union_all([Il1, Is1], I1b),
    union_all([Il2, Is2], I2b),
    intersect_all([Ip, I1b, I2b], If), If \= [],
    holdsFor(withinArea(V1, nearCoast)=true, Iw1),
    holdsFor(withinArea(V2, nearCoast)=true, Iw2),
    relative_complement_all(If, [Iw1, Iw2], I).