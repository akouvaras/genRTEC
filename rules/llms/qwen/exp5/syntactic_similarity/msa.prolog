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
    intDurGreater(Iu, aOrMTime, I).

%--------------- tugging (B) ----------------%

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
    thresholds(tuggingMax, TuggingMax),
    Speed < TuggingMin.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    oneIsTug(Vessel1, Vessel2),
    not oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(hasTuggingSpeed(Vessel1)=true, I1),
    holdsFor(hasTuggingSpeed(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], Ii),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(Ii, tuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax,
    holdsAt(withinArea(Vessel, fishingZone)=true, T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed < TrawlingspeedMin.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    velocity(Vessel, Speed, _, _),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed > TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, fishingZone).

%--------------- trawling --------------------%

holdsFor(movementIsTrawling(Vessel)=true, I) :-
    holdsFor(withinArea(Vessel, fishingZone)=true, I).

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
    thresholds(sarDuration, SarDuration),
    intDurGreater(Ii, sarDuration, I).

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
    intDurGreater(IPure, loiteringTime, I).

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