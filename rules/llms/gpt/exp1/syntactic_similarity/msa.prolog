%--------------- communication gap -----------%

initiatedAt(gap(Vessel) = nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts) = true, T).

initiatedAt(gap(Vessel) = farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    not holdsAt(withinArea(Vessel, nearPorts) = true, T).

terminatedAt(gap(Vessel) = _Status, T) :-
    happensAt(gap_end(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel) = true, T) :-
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel) = true, T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel) = true, T) :-
    happensAt(start(gap(Vessel) = _GapStatus), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(hcNearCoastMax, MaxSafe),
    Speed > MaxSafe,
    holdsAt(withinArea(Vessel, nearCoast) = true, T).

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(hcNearCoastMax, MaxSafe),
    Speed =< MaxSafe.

terminatedAt(highSpeedNearCoast(Vessel) = true, T) :-
    happensAt(end(withinArea(Vessel, nearCoast) = true), T).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel) = true, I) :-
    holdsFor(stopped(Vessel) = farFromPorts, IsFar),
    holdsFor(withinArea(Vessel, anchorage) = true, Ia),
    intersect_all([IsFar, Ia], I1),
    holdsFor(stopped(Vessel) = nearPorts, I2),
    union_all([I1, I2], Ii),
    intDurGreater(Ii, aOrMTime, I).

%---------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, MinS),
    thresholds(tuggingMax, MaxS),
    Speed >= MinS, 
    Speed =< MaxS.

terminatedAt(tuggingSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, MinS),
    thresholds(tuggingMax, MaxS),
    Speed < MinS.

terminatedAt(tuggingSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, MinS),
    thresholds(tuggingMax, MaxS),
    Speed > MaxS.

terminatedAt(tuggingSpeed(Vessel) = true, T) :-
    happensAt(start(gap(Vessel) = _GapStatus), T).

holdsFor(tugging(Vessel1, Vessel2) = true, I) :-
    Vessel1 \= Vessel2,
    Vessel1 @< Vessel2,                     
    not oneIsPilot(Vessel1, Vessel2),
    oneIsTug(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2) = true, Ip),
    holdsFor(tuggingSpeed(Vessel1) = true, I1),
    holdsFor(tuggingSpeed(Vessel2) = true, I2),
    intersect_all([Ip, I1, I2], Ii),
    intDurGreater(Ii, tuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(trawlingSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, MinS),
    thresholds(trawlingspeedMax, MaxS),
    Speed >= MinS, Speed =< MaxS,
    holdsAt(withinArea(Vessel, fishingArea) = true, T).

terminatedAt(trawlingSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, MinS),
    thresholds(trawlingspeedMax, MaxS),
    Speed < MinS.

terminatedAt(trawlingSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, MinS),
    thresholds(trawlingspeedMax, MaxS),
    Speed > MaxS.

terminatedAt(trawlingSpeed(Vessel) = true, T) :-
    happensAt(start(gap(Vessel) = _GapStatus), T).

terminatedAt(trawlingSpeed(Vessel) = true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea) = true), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMotion(Vessel) = true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea) = true, T).

terminatedAt(trawlingMotion(Vessel) = true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea) = true), T).

holdsFor(trawling(Vessel) = true, I) :-
    holdsFor(trawlingSpeed(Vessel) = true, I1),
    holdsFor(trawlingMotion(Vessel) = true, I2),
    intersect_all([I1, I2], Ii),
    intDurGreater(Ii, trawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, SarMin),
    Speed >= SarMin.

terminatedAt(sarSpeed(Vessel) = true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, SarMin),
    Speed < SarMin.

terminatedAt(sarSpeed(Vessel) = true, T) :-
    happensAt(start(gap(Vessel) = _GapStatus), T).

initiatedAt(sarMotion(Vessel) = true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMotion(Vessel) = true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMotion(Vessel) = true, T) :-
    happensAt(start(gap(Vessel) = _GapStatus), T).

holdsFor(inSAR(Vessel) = true, I) :-
    holdsFor(sarSpeed(Vessel)  = true, I1),
    holdsFor(sarMotion(Vessel) = true, I2),
    intersect_all([I1, I2], Ii),
    intDurGreater(Ii, sarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel) = true, I) :-
    holdsFor(lowSpeed(Vessel) = true, Ilow),
    holdsFor(stopped(Vessel) = farFromPorts, IstoppedFar),
    union_all([Ilow, IstoppedFar], Imove),
    holdsFor(withinArea(Vessel, nearCoast) = true, INearCoast),
    relative_complement_all(Imove, [INearCoast], Ioffshore),
    holdsFor(anchoredOrMoored(Vessel) = true, IAorM),
    relative_complement_all(Ioffshore, [IAorM], Ii),
    intDurGreater(Ii, loiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2) = true, I) :-
    Vessel1 \= Vessel2,
    Vessel1 @< Vessel2,                              
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2) = true, Ip),
    holdsFor(lowSpeed(Vessel1) = true, Il1),
    holdsFor(stopped(Vessel1) = farFromPorts, Is1),
    union_all([Il1, Is1], I1b),
    holdsFor(lowSpeed(Vessel2) = true, Il2),
    holdsFor(stopped(Vessel2) = farFromPorts, Is2),
    union_all([Il2, Is2], I2b),
    intersect_all([I1b, I2b, Ip], If), If \= [],
    holdsFor(withinArea(Vessel1, nearCoast) = true, Iw1),
    holdsFor(withinArea(Vessel2, nearCoast) = true, Iw2),
    relative_complement_all(If, [Iw1, Iw2], I).